require "test_helper"

class Admin::MealTypes::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @meal_type = meal_types(:one)
    @facade = Admin::MealTypes::EditFacade.new(@user, { id: @meal_type.id })
  end

  def test_meal_type
    assert_equal @meal_type, @facade.meal_type
  end

  def test_active_key
    assert_equal :admin_meal_types, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Meal Types", trail[1].text
    assert_equal "Edit", trail[2].text
  end
end
