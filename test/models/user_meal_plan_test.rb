require "test_helper"

class UserMealPlanTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to :user
    should belong_to :meal_plan
  end
end
