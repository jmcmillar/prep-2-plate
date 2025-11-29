require "test_helper"

class Api::ShoppingLists::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @facade = Api::ShoppingLists::NewFacade.new(@user, {})
  end

  def test_initialization
    assert_not_nil @facade
  end
end
