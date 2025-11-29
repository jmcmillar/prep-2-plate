require "test_helper"

class Admin::RecipeIngredients::DestroyFacadeTest < ActiveSupport::TestCase
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
    @facade = Admin::RecipeIngredients::DestroyFacade.new(@admin, { id: @recipe_ingredient.id })
  end

  def test_recipe_ingredient
    assert_equal @recipe_ingredient, @facade.recipe_ingredient
  end
end
