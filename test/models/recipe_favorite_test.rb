require "test_helper"

class RecipeFavoriteTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:user)
    should belong_to(:recipe)
  end
end
