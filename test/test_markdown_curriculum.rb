require_relative "./helper"

class TestMarkdownCurriculum < Minitest::Test
  def self.title = "My Ruby road map"

  # DSL for defining data for a test case.
  def self.example(description, markdown:, parsed:)
    @cases ||= []
    @cases << [description, markdown, parsed]
  end

  # Shortcut for the :parsed value in the previous ::example data.
  def self.prev_parsed
    @cases.last.last
  end

  # Data for test cases.

  example "blank file",
    markdown: "\n",
    parsed: { title: nil, intro: nil, content: {} }

  example "title",
    markdown: "# #{title}\n",
    parsed: { title:, intro: nil, content: {} }

  example "empty sections",
    markdown: <<~MD,
      # #{title}

      ## Intro


      ## Basics

    MD
    parsed: {
      title:,
      intro: nil,
      content: { "Intro" => nil, "Basics" => nil },
    }

  example "empty sections with minimal line breaks",
    markdown: <<~MD,
      # #{title}
      ## Intro
      ## Basics
    MD
    parsed: prev_parsed

  example "table of contents",
    markdown: <<~MD,
      # #{title}
      ## Table of contents
      ## Intro
      <!-- omit in toc -->
      ## Basics
    MD
    parsed: prev_parsed

  example "empty subsections",
    markdown: <<~MD,
      # #{title}

      ## Advanced


      ### Quantum computing


      ### The meaning of life

      ## Galaxy brain
    MD
    parsed: {
      title:,
      intro: nil,
      content: {
        "Advanced" => {
          "Quantum computing" => nil,
          "The meaning of life" => nil,
        },
        "Galaxy brain" => nil,
      },
    }

  example "empty subsections with minimal line breaks",
    markdown: <<~MD,
      # #{title}
      ## Advanced
      ### Quantum computing
      ### The meaning of life
      ## Galaxy brain
    MD
    parsed: prev_parsed

  example "content under sections",
    markdown: <<~MD,
      # #{title}
      ## Basics

      - [x] [The Odin Project - Ruby](https://www.theodinproject.com/paths/full-stack-ruby-on-rails/courses/ruby) <!-- https://example.com/top.png -->
      - [x] [GoRails - Ruby for Beginners](https://gorails.com/series/ruby-for-beginners) if you prefer videos. <!-- https://example.com/gorails.png -->
      - [ ] [Try Ruby](https://try.ruby-lang.org/) and [BigBinary Academy](https://academy.bigbinary.com/learn-ruby) if you prefer an interactive approach.

      ## Advanced

      - something <!-- https://example.com/something.png -->
      - more
    MD
    parsed: {
      title:,
      intro: nil,
      content: {
        "Basics" => [
          {
            title: "The Odin Project - Ruby",
            url: "https://www.theodinproject.com/paths/full-stack-ruby-on-rails/courses/ruby",
            description: nil,
            image: "https://example.com/top.png",
          },
          {
            title: "GoRails - Ruby for Beginners",
            url: "https://gorails.com/series/ruby-for-beginners",
            description: "if you prefer videos.",
            image: "https://example.com/gorails.png",
          },
        ],
        "Advanced" => [
          {
            title: "something",
            url: nil,
            description: nil,
            image: "https://example.com/something.png",
          },
          {
            title: "more",
            url: nil,
            description: nil,
            image: nil,
          },
        ],
      },
    }

  # Test cases generated from the data above.
  @cases.each do |description, markdown, expected|
    define_method "test_#{description.tr(" ", "_")}" do
      actual = MarkdownCurriculum.new(markdown).parse
      assert_equal expected, actual
    end
  end

  # TODO
  # <<~MD
  #   # My Ruby road map

  #   Hi, this is my road map.

  #   ## Table of contents

  #   (This section should be omitted.)

  #   ## Intro

  #   This section might contain prose.

  #   ## Basics

  #   ### Ruby basics

  #   - **Intro:**
  #     - [x] [The Odin Project - Ruby](https://www.theodinproject.com/paths/full-stack-ruby-on-rails/courses/ruby) <!-- https://example.com/top.png -->
  #     - [x] [GoRails - Ruby for Beginners](https://gorails.com/series/ruby-for-beginners) if you prefer videos. <!-- https://example.com/gorails.png -->
  #     - [ ] [Try Ruby](https://try.ruby-lang.org/) and [BigBinary Academy](https://academy.bigbinary.com/learn-ruby) if you prefer an interactive approach.

  #   ## Advanced concepts

  #   ### Quantum computing

  #   - something

  #   ### The meaning of life

  #   - something else
  # MD

  # expected = [
  #   {
  #     "Basics" =>
  #       [
  #         {
  #           "Ruby basics" =>
  #             [
  #               {
  #                 "Intro" =>
  #                   [
  #                     {
  #                       title: "The Odin Project - Ruby",
  #                       description: nil,
  #                       url: "https://www.theodinproject.com/paths/full-stack-ruby-on-rails/courses/ruby",
  #                       image: "https://avatars.githubusercontent.com/u/4441966?s=280",
  #                     },
  #                     {
  #                       title: "GoRails - Ruby for Beginners",
  #                       description: "If you prefer videos.",
  #                       url: "https://gorails.com/series/ruby-for-beginners",
  #                       image: nil,
  #                     },
  #                   ],
  #               },
  #             ],
  #         },
  #       ],
  #   },
  # ]
end
