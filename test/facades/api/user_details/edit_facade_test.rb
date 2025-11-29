require "test_helper"

class Api::UserDetails::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @facade = Api::UserDetails::EditFacade.new(@user, {})
  end

  def test_user
    assert_equal @user, @facade.user
  end
end
