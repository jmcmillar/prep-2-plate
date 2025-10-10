require "test_helper"

class RecipeImportTest < ActiveSupport::TestCase
  context "validations" do
    should validate_presence_of(:url)
    should validate_uniqueness_of(:url).case_insensitive
  end

  context "associations" do
    should have_many(:recipes).class_name("Recipe")
  end
end
