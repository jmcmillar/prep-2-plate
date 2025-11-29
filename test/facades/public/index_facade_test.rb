require "test_helper"

class Public::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @facade = Public::IndexFacade.new(@user, {})
  end

  def test_recipes
    recipes = @facade.recipes
    
    assert_kind_of Array, recipes
  end

  def test_meal_plans
    meal_plans = @facade.meal_plans
    
    assert_kind_of ActiveRecord::Relation, meal_plans
  end
end
