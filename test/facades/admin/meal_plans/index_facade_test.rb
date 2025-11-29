require "test_helper"

class Admin::MealPlans::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @meal_plan = meal_plans(:one)
    @facade = Admin::MealPlans::IndexFacade.new(@user, {})
  end

  def test_active_key
    assert_equal :admin_meal_plans, @facade.active_key
  end

  def test_base_collection
    assert_includes @facade.base_collection, @meal_plan
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 2, trail.length
    assert_equal "Admin", trail.first.text
    assert_equal "Meal Plans", trail.last.text
  end

  def test_new_action_data
    action = @facade.new_action_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal "New Meal Plan", action.label
  end

  def test_resource_facade_class
    assert_equal Admin::MealPlans::ResourceFacade, @facade.resource_facade_class
  end
end
