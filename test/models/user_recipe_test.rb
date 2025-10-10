require "test_helper"

class UserRecipeTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:user)
    should belong_to(:recipe)
  end
end
