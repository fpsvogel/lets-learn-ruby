class MarkdownCurriculum
  private attr_reader :markdown_string, :config

  def initialize(markdown_string, custom_config: {})
    @markdown_string = markdown_string
    @config = custom_config.with_defaults(default_config)
  end

  # Parses the Markdown curriculum into groups of item hashes.
  # @return [Array<Hash>] nested item groups containing item hashes.
  #   For example, here's a snipped from a Markdown curriculum:
  #     ```markdown
  #     ## Basics
  #
  #     ### Ruby basics
  #
  #     - **Intro:**
  #       - [x] [The Odin Project - Ruby](https://www.theodinproject.com/paths/full-stack-ruby-on-rails/courses/ruby) <!-- https://avatars.githubusercontent.com/u/4441966?s=280 -->
  #       - [x] [GoRails - Ruby for Beginners](https://gorails.com/series/ruby-for-beginners) if you prefer videos.
  #       - [ ] [BigBinary Academy](https://academy.bigbinary.com/learn-ruby)
  #     ```
  #
  #   From the above Markdown, this data is parsed:
  #     ```ruby
  #     [
  #       {
  #         "Basics" =>
  #           [
  #             {
  #               "Ruby basics" =>
  #                 [
  #                   {
  #                     "Intro" =>
  #                       [
  #                         {
  #                           title: "The Odin Project - Ruby",
  #                           description: nil,
  #                           url: "https://www.theodinproject.com/paths/full-stack-ruby-on-rails/courses/ruby",
  #                           image: "https://avatars.githubusercontent.com/u/4441966?s=280",
  #                         },
  #                         {
  #                           title: "GoRails - Ruby for Beginners",
  #                           description: "If you prefer videos.",
  #                           url: "https://gorails.com/series/ruby-for-beginners",
  #                           image: nil,
  #                         },
  #                       ],
  #                   },
  #                 ],
  #             },
  #           ],
  #       },
  #     ]
  #    ```
  def parse
    markdown_string
      .split("## ")
      .reject(&:blank?)
  end

  private

  def default_config
    { ignore_completed: true }
  end
end