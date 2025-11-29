require "test_helper"

class Admin::MealTypes::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @meal_type = meal_types(:one)
    @facade = Admin::MealTypes::IndexFacade.new(@user, {})
  end

  def test_active_key
    assert_equal :admin_meal_types, @facade.active_key
  end

  def test_base_collection
    assert_includes @facade.base_collection, @meal_type
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 2, trail.length
    assert_equal "Admin", trail.first.text
    assert_equal "Meal Types", trail.last.text
  end

  def test_new_action_data
    action = @facade.new_action_data
    
    assert_kind_of IconLinkComponent::Data, action
  end
end
