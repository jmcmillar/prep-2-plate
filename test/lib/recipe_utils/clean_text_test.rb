require "test_helper"

class RecipeUtils::CleanTextTest < ActiveSupport::TestCase
  def test_decodes_html_entities
    assert_equal "Mom's 1 ½ cup pie & more", RecipeUtils::CleanText.call("Mom&#39;s 1 &frac12; cup pie &amp; more")
  end

  def test_strips_tags_and_collapses_whitespace
    assert_equal "Stir well then serve", RecipeUtils::CleanText.call("<p>Stir <a href='#'>well</a>\n\n then   serve</p>")
  end

  def test_removes_checkbox_bullets_and_non_breaking_spaces
    assert_equal "2 cups flour", RecipeUtils::CleanText.call("▢ 2 cups flour")
  end

  def test_returns_non_strings_unchanged
    assert_nil RecipeUtils::CleanText.call(nil)
    assert_equal 4, RecipeUtils::CleanText.call(4)
  end
end
