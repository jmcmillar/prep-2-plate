require "test_helper"

class RecipeCategoryAssignmentTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:recipe)
    should belong_to(:recipe_category)
  end
end
