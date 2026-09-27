require "test_helper"

class Admin::RecipeImports::Ingredients::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @recipe_import = RecipeImport.create!(url: "https://example.com/recipe")
    @recipe = Recipe.create!(
      name: "Test Recipe",
      recipe_import: @recipe_import
    )
    @facade = Admin::RecipeImports::Ingredients::NewFacade.new(@admin, { recipe_id: @recipe.id })
  end

  def test_recipe
    assert_equal @recipe, @facade.recipe
  end

  def test_import_url
    assert_equal "https://example.com/recipe", @facade.import_url
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 4, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Recipes", trail[1].text
    assert_equal "Import Ingredients", trail[3].text
  end

  def test_build_ingredient_list_schedules_categorization
    params = {
      recipe_id: @recipe.id,
      recipe: { recipe_ingredients_attributes: [ { quantity: "1", ingredient_name: "schedule test onion" } ] }
    }
    facade = Admin::RecipeImports::Ingredients::NewFacade.new(@admin, params)
    scheduled = 0

    RecipeImports::ScheduleIngredientCategorization.stub(:call, -> { scheduled += 1 }) { facade.build_ingredient_list }

    assert_equal 1, scheduled
    assert Ingredient.exists?(name: "schedule test onion")
  end

  def test_form_url
    expected = {
      controller: "admin/recipe_imports/ingredients",
      action: "create",
      recipe_id: @recipe.id
    }
    assert_equal expected, @facade.form_url
  end
end
