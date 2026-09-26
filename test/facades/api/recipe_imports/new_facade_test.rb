require "test_helper"

class Api::RecipeImports::NewFacadeTest < ActiveSupport::TestCase
  PageResponse = Struct.new(:body, :headers)

  def setup
    @user = users(:one)
    @facade = Api::RecipeImports::NewFacade.new(@user, { url: "https://example.com/soup" })
  end

  def test_builds_recipe_owned_by_user
    with_page("hash_context_after_bad_json.html") do
      assert_equal "Simple Soup", @facade.recipe.name
      assert_equal @user, @facade.recipe.user_recipe.user
      assert @facade.recipe.recipe_import.new_record?
    end
  end

  def test_save_persists_recipe_import_and_ownership_together
    with_page("hash_context_after_bad_json.html") do
      assert_difference([ "Recipe.count", "RecipeImport.count", "UserRecipe.count" ], 1) { assert @facade.save }
    end
  end

  def test_save_fails_without_recipe
    Import::SafeFetch.stub(:get, PageResponse.new("<html></html>", {})) do
      assert_not @facade.save
      assert_equal [ Api::RecipeImports::NewFacade::NOT_FOUND_ERROR ], @facade.errors
    end
  end

  private

  def with_page(fixture, &block)
    Import::SafeFetch.stub(:get, PageResponse.new(file_fixture("recipe_pages/#{fixture}").read, {}), &block)
  end
end
