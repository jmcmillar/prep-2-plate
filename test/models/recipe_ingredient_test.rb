require "test_helper"

class RecipeIngredientTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:recipe)
    should belong_to(:ingredient)
    should belong_to(:measurement_unit).optional
  end

  context "delegations" do
    should delegate_method(:name).to(:measurement_unit).with_prefix
    should delegate_method(:name).to(:ingredient).with_prefix
  end
end
