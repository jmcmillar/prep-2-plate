require "test_helper"

class RecipeImportTest < ActiveSupport::TestCase

  def test_keeps_https_image_urls
    assert_equal "https://example.com/a.jpg", RecipeImport.new(image_url: "https://example.com/a.jpg").image_url
  end

  def test_upgrades_http_image_urls
    assert_equal "https://example.com/a.jpg", RecipeImport.new(image_url: " http://example.com/a.jpg ").image_url
  end

  def test_drops_image_urls_that_are_not_web_links
    [ "data:image/png;base64,abc", "/relative.jpg", "not a url", nil ].each do |value|
      assert_nil RecipeImport.new(image_url: value).image_url, value.inspect
    end
  end
end
