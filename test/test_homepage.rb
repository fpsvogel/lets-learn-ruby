require_relative "helper"

class TestHomepage < Minitest::Test
  def test_homepage_exists
    page = site.collections.pages.resources.find { |doc| doc.relative_url == "/" }
    document_root page
    assert_select "body"
  end
end
