require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  context "validations" do
    should validate_presence_of(:name)
    should validate_uniqueness_of(:name).case_insensitive
  end

  context "associations" do
    should have_many(:recipe_ingredients).dependent(:restrict_with_error)
  end
end
