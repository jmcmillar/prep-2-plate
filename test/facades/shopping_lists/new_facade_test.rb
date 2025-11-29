require "test_helper"

class ShoppingLists::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @facade = ShoppingLists::NewFacade.new(@user, {})
  end

  def test_shopping_list_is_not_persisted
    assert @facade.shopping_list.new_record?
  end

  def test_shopping_list_belongs_to_user
    assert_equal @user, @facade.shopping_list.user
  end

  def test_form_url
    expected = { controller: "shopping_lists", action: "create" }
    assert_equal expected, @facade.form_url
  end

  def test_cancel_path
    expected = { controller: "shopping_lists", action: "index" }
    assert_equal expected, @facade.cancel_path
  end
end
