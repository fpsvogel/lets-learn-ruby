class MarkdownCurriculum
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
      .gsub("<!-- omit in toc -->", "")
      # Get sections (h2).
      .split("\n## ")
      .map { |h2_and_content|
        h2_and_content.split("\n", 2)
      }
      # Split out the title and top content.
      .then {
        title, intro = _1.shift
        title = title&.delete_prefix("# ")&.strip&.presence
        intro = intro&.strip&.presence

        {
          title:,
          intro:,
          content: _1,
        }
      }
      .tap { |hash|
        hash[:content] = hash[:content]
          # For empty sections, add nil to form a 2-element (#to_h-able) array.
          .map { |array|
            (2 - array.length).times.inject(array) { |array, i| array << nil }
          }
          .to_h
          .transform_keys(&:strip)
          .transform_values { _1&.strip&.presence }
          .reject { |k, v| ["table of contents", "preliminaries"].include?(k.downcase) }
          # Get subsections (h3).
          .transform_values.with_index { |content_under_h2, i|
            next nil if content_under_h2.nil?
            next parse_list(content_under_h2) unless content_under_h2.include?("\n### ")

            content_under_h2
              .split(/\n### /)
              .map { |h3_and_content|
                h3_and_content.delete_prefix("### ").split("\n", 2)
              }
              # For empty subsections, add nil to form a 2-element (#to_h-able) array.
              .map { |array|
                (2 - array.length).times.inject(array) { |array, i| array << nil }
              }
              .to_h
              .transform_values { _1&.strip&.presence }
          }
      }
  end

  private

  def default_config
    { ignore_incomplete: true }
  end

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
                (\*|-) # bullet
                \s*
                (\[(x|\s)\])? # check box
              )
              \s*
              (
                (
                  \[
                    (?<title>.+)
                  \]
                  \(
                    (?<url>.+)
                  \)
                  \s*
                  (
                    (?<description>.*?)
                  )?
                )
                |
                (?<title>.+?)
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
          .named_captures
          .transform_values { _1&.strip&.presence }
          .transform_keys(&:to_sym)
      }
  end
end