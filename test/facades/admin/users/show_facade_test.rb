require "test_helper"

class Admin::Users::ShowFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @user = users(:two)
    @facade = Admin::Users::ShowFacade.new(@admin, { id: @user.id })
  end

  def test_resource
    assert_equal @user, @facade.resource
  end

  def test_active_key
    assert_equal :admin_user, @facade.active_key
  end

  def test_menu
    assert_equal :admin_user_menu, @facade.menu
  end

  def test_nav_resource
    assert_equal @user, @facade.nav_resource
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Users", trail[1].text
  end

  def test_edit_action_data
    action = @facade.edit_action_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal "User", action.label
  end
end
