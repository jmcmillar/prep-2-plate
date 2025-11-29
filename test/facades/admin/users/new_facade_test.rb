require "test_helper"

class Admin::Users::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @facade = Admin::Users::NewFacade.new(@admin, {})
  end

  def test_resource
    resource = @facade.resource
    
    assert_kind_of User, resource
    assert resource.new_record?
    assert_not_nil resource.password
  end

  def test_active_key
    assert_equal :admin_users, @facade.active_key
  end

  def test_form_url
    expected = {
      controller: "admin/users",
      action: "create"
    }
    assert_equal expected, @facade.form_url
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Users", trail[1].text
    assert_equal "New", trail[2].text
  end
end
