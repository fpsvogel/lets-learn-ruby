require_relative "./helper"

class TestMarkdownCurriculum < Minitest::Test
  def self.title = "My Ruby road map"

  @cases = {

  "blank file" => [
    "\n",
    { title: nil, intro: nil, content: {} },
  ],

  "title" => [
    "# #{title}\n",
    { title:, intro: nil, content: {} },
  ],

  "title and empty sections" => [
    <<~MARKDOWN,
      # #{title}

      ## Intro


      ## Basics

    MARKDOWN
    {
      title:,
      intro: nil,
      content: { "Intro" => nil, "Basics" => nil },
    },
  ],

  "title and empty sections with minimal line breaks" => [
    <<~MARKDOWN,
      # #{title}
      ## Intro
      ## Basics
    MARKDOWN
    {
      title:,
      intro: nil,
      content: { "Intro" => nil, "Basics" => nil },
    },
  ],

  }

  @cases.each do |description, (markdown, expected)|
    define_method "test_#{description.tr(" ", "_")}" do
      actual = MarkdownCurriculum.new(markdown).parse
      assert_equal expected, actual
    end
  end

  # TODO
  # <<~MARKDOWN
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
  # MARKDOWN

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
