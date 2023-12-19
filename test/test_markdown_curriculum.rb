require_relative "./helper"

class TestMarkdownCurriculum < Minitest::Test
  def self.title = "My Ruby road map"

  # DSL for defining data for a test case.
  def self.example(description, markdown:, parsed:)
    @cases ||= []
    @cases << [description, markdown, parsed]
  end

  # Data for test cases.

  example "blank file",
    markdown: "\n",
    parsed: { title: nil, intro: nil, content: {} }

  example "title",
    markdown: "# #{title}\n",
    parsed: { title:, intro: nil, content: {} }

  example "title and empty sections",
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

  example "title and empty sections with minimal line breaks",
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
  #     - [x] [The Odin Project - Ruby](https://www.theodinproject.com/paths/full-stack-ruby-on-rails/courses/ruby) <!-- https://avatars.githubusercontent.com/u/4441966?s=280 -->
  #     - [x] [GoRails - Ruby for Beginners](https://gorails.com/series/ruby-for-beginners) if you prefer videos.
  #     - [ ] [BigBinary Academy](https://academy.bigbinary.com/learn-ruby)

  #   ## Advanced concepts

  #   ### Quantum computing

  #   - [ ] something

  #   ### The meaning of life

  #   - [ ] something else
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
