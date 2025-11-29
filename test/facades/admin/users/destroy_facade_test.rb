require "test_helper"

class Admin::Users::DestroyFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @user = users(:two)
    @facade = Admin::Users::DestroyFacade.new(@admin, { id: @user.id })
  end

  def test_resource
    assert_equal @user, @facade.resource
  end
end
