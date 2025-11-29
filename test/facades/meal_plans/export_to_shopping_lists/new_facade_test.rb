require "test_helper"

class MealPlans::ExportToShoppingLists::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @meal_plan = @user.meal_plans.create!(name: "Test Meal Plan")
    @facade = MealPlans::ExportToShoppingLists::NewFacade.new(@user, { meal_plan_id: @meal_plan.id })
  end

  def test_meal_plan
    assert_equal @meal_plan, @facade.meal_plan
  end

  def test_shopping_lists
    lists = @facade.shopping_lists
    
    assert_kind_of ActiveRecord::Relation, lists
  end

  def test_ingredients
    ingredients = @facade.ingredients
    
    assert_kind_of ActiveRecord::Relation, ingredients
  end

  def test_active_key
    assert_equal :meal_plans, @facade.active_key
  end

  def test_form_url
    assert_equal [@meal_plan, :export_to_shopping_list], @facade.form_url
  end

  def test_shopping_list_new_when_no_id
    list = @facade.shopping_list
    
    # Returns nil when no strong_params provided
    assert_nil list
  end
end
