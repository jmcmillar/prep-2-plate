require "test_helper"

class Admin::RecipeIngredients::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @recipe = recipes(:one)
    @ingredient = ingredients(:one)
    @unit = measurement_units(:one)
    @recipe_ingredient = @recipe.recipe_ingredients.create!(
      ingredient: @ingredient,
      measurement_unit: @unit,
      numerator: 1,
      denominator: 1
    )
    @facade = Admin::RecipeIngredients::EditFacade.new(@admin, { id: @recipe_ingredient.id })
  end

  def test_recipe_ingredient
    assert_equal @recipe_ingredient, @facade.recipe_ingredient
  end

  def test_recipe
    assert_equal @recipe, @facade.recipe
  end

  def test_active_key
    assert_equal :admin_recipes, @facade.active_key
  end

  def test_measurement_units
    units = @facade.measurement_units
    
    assert_kind_of ActiveRecord::Relation, units
  end

  def test_ingredients
    ingredients = @facade.ingredients
    
    assert_kind_of ActiveRecord::Relation, ingredients
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Recipe Ingredients", trail[1].text
    assert_equal "Edit", trail[2].text
  end
end
