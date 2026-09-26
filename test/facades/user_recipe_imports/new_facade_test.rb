require "test_helper"

class UserRecipeImports::NewFacadeTest < ActiveSupport::TestCase
  PageResponse = Struct.new(:body, :headers)

  def setup
    @user = users(:one)
    @url = "https://example.com/recipe"
    @facade = UserRecipeImports::NewFacade.new(@user, {}, strong_params: { url: @url })
  end

  def test_builds_recipe_with_ingredients_and_owner
    with_page(file_fixture("recipe_pages/wprm_graph.html").read) do
      recipe = @facade.recipe

      assert_empty recipe.errors
      assert_equal "Grandma's Lemon Bars", recipe.name
      assert_equal 3, recipe.recipe_ingredients.size
      assert_equal @user, recipe.user_recipe.user
    end
  end

  def test_missing_recipe_adds_errors_to_recipe_and_import
    with_page("<html></html>") do
      recipe = @facade.recipe

      assert_not_empty recipe.errors
      assert_includes @facade.recipe_import.errors.full_messages.join, "Recipe name is required"
    end
  end

  def test_fetch_failure_becomes_form_error
    Import::SafeFetch.stub(:get, ->(*) { raise Import::SafeFetch::FetchError, "returned HTTP 403" }) do
      recipe = @facade.recipe

      assert_not_empty recipe.errors
      assert_match "403", @facade.recipe_import.errors.full_messages.first
    end
  end

  private

  def with_page(body, &block)
    Import::SafeFetch.stub(:get, PageResponse.new(body, {}), &block)
  end
end
