require "test_helper"

class Admin::Users::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @facade = Admin::Users::IndexFacade.new(@user, {})
  end

  def test_active_key
    assert_equal :admin_users, @facade.active_key
  end

  def test_base_collection
    assert_includes @facade.base_collection, @user
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 2, trail.length
    assert_equal "Admin", trail.first.text
    assert_equal "Users", trail.last.text
  end

  def test_new_action_data
    action = @facade.new_action_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal "New User", action.label
  end

  def test_resource_facade_class
    assert_equal Admin::Users::ResourceFacade, @facade.resource_facade_class
  end
end
