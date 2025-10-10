require "test_helper"

class ShoppingListItemTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to :shopping_list
  end

  # context "validations" do
  #   should_belong_to :shopping_list
  # end
end
