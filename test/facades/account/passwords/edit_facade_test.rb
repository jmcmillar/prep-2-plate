require "test_helper"

class Account::Passwords::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @facade = Account::Passwords::EditFacade.new(@user, {})
  end

  def test_user
    assert_equal @user, @facade.user
  end

  def test_active_key
    assert_equal :password, @facade.active_key
  end

  def test_menu
    assert_equal :account_setting_menu, @facade.menu
  end
end
