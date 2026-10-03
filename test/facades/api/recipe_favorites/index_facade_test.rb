require "test_helper"

class Api::RecipeFavorites::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @user.recipe_favorites.find_or_create_by!(recipe: @recipe)
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

  def test_search_filters_every_section_by_name
    imported = Recipe.create!(name: "Imported Tacos", recipe_import: RecipeImport.create!(url: "https://example.com/tacos"))
    created = Recipe.create!(name: "Fish Tacos")
    other = Recipe.create!(name: "Pancakes")
    [ imported, created, other ].each { |recipe| @user.user_recipes.create!(recipe: recipe) }

    facade = Api::RecipeFavorites::IndexFacade.new(@user, { q: { name_cont: "taco" } })

    assert_empty facade.favorite_recipes
    assert_equal [ imported ], facade.imported_recipes.to_a
    assert_equal [ created ], facade.user_recipes.to_a
  end
end
