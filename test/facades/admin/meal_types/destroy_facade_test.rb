require "test_helper"

class Admin::MealTypes::DestroyFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @meal_type = meal_types(:one)
    @facade = Admin::MealTypes::DestroyFacade.new(@admin, { id: @meal_type.id })
  end

  def test_meal_type
    assert_equal @meal_type, @facade.meal_type
  end
end
