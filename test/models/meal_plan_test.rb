require "test_helper"

class MealPlanTest < ActiveSupport::TestCase
  context "validations" do
    should validate_presence_of(:name)
    should validate_uniqueness_of(:name).case_insensitive
  end

  context "associations" do
    should have_many(:meal_plan_recipes).dependent(:destroy)
    should have_many(:recipes).through(:meal_plan_recipes)
    should have_many(:ingredients).through(:recipes)
  end
end
