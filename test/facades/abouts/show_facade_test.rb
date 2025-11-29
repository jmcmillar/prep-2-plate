require "test_helper"

class Abouts::ShowFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @facade = Abouts::ShowFacade.new(@user, {})
  end

  def test_active_key
    assert_equal :none, @facade.active_key
  end
end
