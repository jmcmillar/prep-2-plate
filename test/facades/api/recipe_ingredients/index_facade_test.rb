require "test_helper"

class Api::RecipeIngredients::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @facade = Api::RecipeIngredients::IndexFacade.new(@user, { recipe_ids: [@recipe.id] })
  end

  def test_current_shopping_list_id
    # Clear any existing current shopping lists first
    @user.shopping_lists.update_all(current: false)
    shopping_list = @user.shopping_lists.create!(name: "Current List", current: true)
    
    assert_equal shopping_list.id, @facade.current_shopping_list_id
  end

  def test_current_shopping_list_id_when_none
    @user.shopping_lists.update_all(current: false)
    
    assert_nil @facade.current_shopping_list_id
  end

  def test_recipe_ingredients
    ingredient = ingredients(:one)
    unit = measurement_units(:one)
    @recipe.recipe_ingredients.create!(ingredient: ingredient, measurement_unit: unit)
    
    ingredients = @facade.recipe_ingredients
    
    assert_kind_of Array, ingredients
  end
end
