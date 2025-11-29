require "test_helper"

class Admin::MealPlans::ShowFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @meal_plan = meal_plans(:one)
    @facade = Admin::MealPlans::ShowFacade.new(@admin, { id: @meal_plan.id })
  end

  def test_meal_plan
    assert_equal @meal_plan, @facade.meal_plan
  end

  def test_active_key
    assert_equal :admin_meal_plans, @facade.active_key
  end

  def test_recipe_ingredients
    ingredients = @facade.recipe_ingredients
    
    assert_kind_of Array, ingredients
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Meal Plans", trail[1].text
  end

  def test_header_actions
    actions = @facade.header_actions
    
    assert_kind_of Array, actions
    assert_equal 2, actions.length
  end

  def test_export_meal_plan_data
    action = @facade.export_meal_plan_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal "Export Meal Plan", action.label
  end

  def test_edit_action_data
    action = @facade.edit_action_data
    
    assert_kind_of IconLinkComponent::Data, action
  end
end
