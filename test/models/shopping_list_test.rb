require "test_helper"

class ShoppingListTest < ActiveSupport::TestCase
  context "associations" do
    should have_many :shopping_list_items
    should belong_to :user
  end

  context "validations" do
    should validate_presence_of :name
  end
end
