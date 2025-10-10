require "test_helper"

class MealPlanRecipeTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:meal_plan)
    should belong_to(:recipe)
    should have_many(:ingredients).through(:recipe)
  end
  context "delegations" do
    should delegate_method(:name).to(:recipe).with_prefix
  end
end
