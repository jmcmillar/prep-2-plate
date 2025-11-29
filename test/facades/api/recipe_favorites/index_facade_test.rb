require "test_helper"

class Api::RecipeFavorites::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @user.recipe_favorites.create!(recipe: @recipe)
    @facade = Api::RecipeFavorites::IndexFacade.new(@user, {})
  end

  def test_favorite_recipes
    assert_includes @facade.favorite_recipes, @recipe
  end

  def test_imported_recipes
    recipe_import = RecipeImport.create!(url: "https://example.com/recipe")
    imported_recipe = Recipe.create!(
      name: "Imported Recipe",
      recipe_import_id: recipe_import.id
    )
    @user.user_recipes.create!(recipe: imported_recipe)
    
    assert_includes @facade.imported_recipes, imported_recipe
  end

  def test_user_recipes
    user_created_recipe = Recipe.create!(
      name: "User Created Recipe",
      recipe_import_id: nil
    )
    @user.user_recipes.create!(recipe: user_created_recipe)
    
    assert_includes @facade.user_recipes, user_created_recipe
  end
end
