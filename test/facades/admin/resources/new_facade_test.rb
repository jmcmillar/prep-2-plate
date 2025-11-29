require "test_helper"

class Admin::Resources::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @facade = Admin::Resources::NewFacade.new(@user, {})
  end

  def test_resource_is_new_record
    assert @facade.resource.new_record?
  end

  def test_active_key
    assert_equal :admin_resources, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Resources", trail[1].text
    assert_equal "New", trail[2].text
  end
end
