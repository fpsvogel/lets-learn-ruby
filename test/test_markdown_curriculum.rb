require_relative "./helper"

class TestHomepage < Minitest::Test
  context "when the curriculum is not empty" do
    should "be true" do
      parsed = MarkdownCurriculum.new("## very ## simple").parse
      assert_equal 2, parsed.count
    end
  end
end
