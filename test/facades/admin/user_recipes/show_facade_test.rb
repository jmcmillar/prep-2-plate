require "test_helper"

class Admin::UserRecipes::ShowFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @user = users(:two)
    @recipe = recipes(:one)
    @user_recipe = @user.user_recipes.create!(recipe: @recipe)
    @facade = Admin::UserRecipes::ShowFacade.new(@admin, { id: @user_recipe.id })
  end

  def test_user_recipe
    assert_equal @user_recipe, @facade.user_recipe
  end

  def test_parent_resource
    assert_equal @user, @facade.parent_resource
  end

  def test_active_key
    assert_equal :admin_recipes, @facade.active_key
  end

  def test_recipe_ingredients
    ingredient = ingredients(:one)
    unit = measurement_units(:one)
    @recipe.recipe_ingredients.create!(ingredient: ingredient, measurement_unit: unit)
    
    ingredients = @facade.recipe_ingredients
    
    assert_kind_of Array, ingredients
  end

  def test_meal_types
    meal_types = @facade.meal_types
    
    assert_kind_of String, meal_types
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 5, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Users", trail[1].text
    assert_equal "Recipes", trail[3].text
  end
end
