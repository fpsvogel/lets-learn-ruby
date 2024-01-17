require "debug"

class MarkdownCurriculum
  class ParsingError < StandardError; end

  private attr_reader :markdown_string, :config

  def initialize(markdown_string, custom_config: {})
    @markdown_string = markdown_string
    @config = custom_config.with_defaults(default_config)
  end

  # Parses the Markdown curriculum into groups of item hashes.
  # @return [Array<Hash>] nested item groups containing item hashes.
  #   See test_markdown_curriculum.rb for examples.
  def parse
    markdown_string
      .gsub("<!-- omit in toc -->\n", "")
      .then { extract_title_and_intro(_1) }
      .then { extract_content(_1) }
  end

  private

  def default_config
    { ignore_incomplete: true }
  end

  # Returns a hash containing the title, intro, and unparsed content from the
  # given string of markdown curriculum.
  def extract_title_and_intro(markdown_string)
    markdown_string
      .split(/\n(?=## )/, 2)
      .then { |title_and_intro, content|
        title, intro = title_and_intro.strip.split("\n", 2)
        title = title&.delete_prefix("# ")&.strip&.presence
        intro = intro&.strip&.presence

        {
          title:,
          intro:,
          content:,
        }
      }
  end

  # Returns a hash containing the title, intro, and *parsed* content from the
  # given hash of title, intro, and unparsed content.
  def extract_content(title_intro_content_hash)
    unless title_intro_content_hash[:content]
      title_intro_content_hash[:content] = {}
      return {
        **title_intro_content_hash,
        content: {},
      }
    end

    heading_strings_and_procs = [
      ["## ", ->(heading) { heading.delete_prefix("## ") }],
      ["### ", ->(heading) { heading.delete_prefix("### ") }],
      ["- **", ->(heading) {
          h4 = heading.match(/- \*\*(.+)\*\*/).captures.first
          h4.delete_suffix(":").delete_suffix(".")
        }
      ],
    ]

    content =
      recursive_parse(
        title_intro_content_hash[:content],
        heading_strings_and_procs:,
        exclude_sections: ["table of contents", "preliminaries"]
      )

    {
      **title_intro_content_hash,
      content:,
    }
  end

  # Recursively parses the given markdown curriculum content.
  # @param content [String] the content of a markdown curriculum.
  # @param heading_strings_and_procs [Array] an array of two-element arrays,
  #   the first element being a string containing the start of each heading line
  #   and the second being a proc that removes the formatting from the heading.
  # @param exculde_sections [Array<String>] lowercased titles of sections to
  #   exclude from the parsed data.
  # @return [Hash] nested hashes; for examples see :content values in
  #   test_markdown_curriculum.rb.
  def recursive_parse(content, heading_strings_and_procs:, exclude_sections: [])
    next_heading_string, next_heading_proc = heading_strings_and_procs.first

    content
      .split(/\n(?=#{Regexp.escape(next_heading_string)})/)
      .reject { !_1.start_with?(next_heading_string) }
      .map { |heading_and_content|
        heading_and_content.strip.split("\n", 2)
      }
      # For empty sections, add nil to form a 2-element (#to_h-able) array.
      .map { |array|
        (2 - array.length).times.inject(array) { |array, i| array << nil }
      }
      .to_h
      .transform_keys(&:strip)
      # Remove formatting from the heading.
      .transform_keys { |formatted_heading|
        next_heading_proc.call(formatted_heading)
      }
      .reject { |k, v| exclude_sections.include?(k.downcase) }
      .transform_values { _1&.strip&.presence }
      .transform_values { |content_under|
        next nil if content_under.nil?

        heading_strings_and_procs_under = heading_strings_and_procs
          .filter {
            heading_string = _1.first
            content_under.match?(/^#{Regexp.escape(heading_string)}/)
          }

        next parse_list(content_under) unless heading_strings_and_procs_under.any?

        recursive_parse(
          content_under,
          heading_strings_and_procs: heading_strings_and_procs_under
        )
      }
  end

  # Parses a list of items, i.e. the innermost parts of the markdown content,
  # excluding headings.
  # @return [Array<Hash>] item hashes.
  def parse_list(markdown_string)
    markdown_string
      .then { |string|
        if config[:ignore_incomplete]
          string.gsub(/\s+- \[ \].+?(\n|\z)/, "")
        else
          string
        end
      }
      .split("\n")
      .map(&:strip)
      .map { |line|
        line
          .match(
            %r{\A
              (
                - # bullet
                \s*
                (\[(x|\s)\])? # check box
              )
              \s*
              (
                (
                  (?<free>💲?)
                  \[
                    (?<title>.+)
                  \]
                  \(
                    (?<url>.+)
                  \)
                  \.?
                  \s*
                  (
                    (?<description>.*?)
                  )?
                )
                |
                (
                  (?<title>.+?)
                  (:|\.)
                  \s+
                  (
                    (?<description>.*?)
                  )?
                )
              )
              (
                \s*
                <!--
                \s*
                (?<image>.+)
                \s*
                -->
              )?
            \z}x
          )
          &.named_captures
          &.transform_values { _1&.strip&.presence }
          &.transform_keys(&:to_sym) ||
            (raise(ParsingError, "Could not parse: #{line}") \
              if line.strip.start_with?("- "))
      }
      .compact
      .each { |item|
        item[:url] ||= item[:description].match(/\[.+?\]\((.+?)\)/)&.captures&.first
        item[:free] = item[:free].blank?
      }
      # Reorder keys, for clearer console/JSON output.
      .map { |item|
        item.slice(:title, :url, :description, :image, :free)
      }
  end
end