require_relative "./helper"

class TestMarkdownCurriculum < Minitest::Test
  def self.title = "My Ruby road map"

  def self.intro = "Hi, this is my road map.\n\nI hope you like it."

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

  example "intro",
    markdown: "# #{title}\n#{intro}",
    parsed: { title:, intro:, content: {} }

  example "empty sections",
    markdown: <<~MD,
      # #{title}

      ## Preface


      ## Basics

    MD
    parsed: {
      title:,
      intro: nil,
      content: { "Preface" => nil, "Basics" => nil },
    }

  example "empty sections with minimal line breaks",
    markdown: <<~MD,
      # #{title}
      ## Preface
      ## Basics
    MD
    parsed: prev_parsed

  example "table of contents",
    markdown: <<~MD,
      # #{title}
      ## Table of contents
      ## Preface
      ## Basics
    MD
    parsed: prev_parsed

  example "'omit in toc' comments",
    markdown: <<~MD,
      <!-- omit in toc -->
      # #{title}
      <!-- omit in toc -->
      ## Preface
      <!-- omit in toc -->
      ## Basics
    MD
    parsed: prev_parsed

  example "'Preliminaries' section",
    markdown: <<~MD,
      # #{title}
      ## Preliminaries
      ## Preface
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

  example "empty subsubsections",
    markdown: <<~MD,
      # #{title}

      ## Advanced

      ### Quantum computing

      - **Basics:**
      - **Experimental tech** that probably should be avoided.

      ### The meaning of life
    MD
    parsed: {
      title:,
      intro: nil,
      content: {
        "Advanced" => {
          "Quantum computing" => {
            "Basics" => nil,
            "Experimental tech" => nil,
          },
          "The meaning of life" => nil,
        },
      },
    }

  example "content under sections",
    markdown: <<~MD,
      # #{title}

      #{intro}

      ## Basics

      Prose under section that is ignored.

      - [x] [The Odin Project - Ruby](https://www.theodinproject.com/paths/full-stack-ruby-on-rails/courses/ruby) <!-- https://example.com/top.png -->
      - [x] [GoRails - Ruby for Beginners](https://gorails.com/series/ruby-for-beginners). Great if you prefer videos. <!-- https://example.com/gorails.png -->
      - [ ] [Try Ruby](https://try.ruby-lang.org/) and [BigBinary Academy](https://academy.bigbinary.com/learn-ruby) if you prefer an interactive approach.

      More prose under section that is ignored.

      ## Intermediate

      - something <!-- https://example.com/something.png -->
      - more
    MD
    parsed: {
      title:,
      intro: intro,
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
            description: "Great if you prefer videos.",
            image: "https://example.com/gorails.png",
          },
        ],
        "Intermediate" => [
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

  example "content under subsections",
    markdown: <<~MD,
      # #{title}

      ## Advanced

      Prose under section that is ignored.

      ### Quantum computing

      Prose under subsection that is ignored.

      - [x] [ABC Bootcamp - Quantum track](https://www.abcbootcamp.com/tracks/quantum) <!-- https://example.com/quantum.png -->

      More prose under subsection that is ignored.
    MD
    parsed: {
      title:,
      intro: nil,
      content: {
        "Advanced" => {
          "Quantum computing" => [
            {
              title: "ABC Bootcamp - Quantum track",
              url: "https://www.abcbootcamp.com/tracks/quantum",
              description: nil,
              image: "https://example.com/quantum.png",
            },
          ],
        },
      },
    }

  example "content under subsubsections",
    markdown: <<~MD,
      # #{title}

      ## Advanced

      ### Quantum computing

      Prose under subsection that is ignored.

      - **Basics:**
        - [x] [ABC Bootcamp - Quantum track](https://www.abcbootcamp.com/tracks/quantum) <!-- https://example.com/quantum.png -->

      More prose under subsection that is ignored.
    MD
    parsed: {
      title:,
      intro: nil,
      content: {
        "Advanced" => {
          "Quantum computing" => {
            "Basics" => [
              {
                title: "ABC Bootcamp - Quantum track",
                url: "https://www.abcbootcamp.com/tracks/quantum",
                description: nil,
                image: "https://example.com/quantum.png",
              },
            ],
          },
        },
      },
    }

  # Test cases generated from the data above.
  @cases.each do |description, markdown, expected|
    define_method "test_#{description.tr(" ", "_")}" do
      actual = MarkdownCurriculum.new(markdown).parse
      assert_equal expected, actual
    end
  end
end
