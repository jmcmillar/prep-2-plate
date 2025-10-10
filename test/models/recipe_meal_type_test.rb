require "test_helper"

class RecipeMealTypeTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:recipe)
    should belong_to(:meal_type)
  end
end
