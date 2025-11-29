require "test_helper"

class Admin::Users::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @user = users(:two)
    @facade = Admin::Users::EditFacade.new(@admin, { id: @user.id })
  end

  def test_resource
    assert_equal @user, @facade.resource
  end

  def test_active_key
    assert_equal :admin_users, @facade.active_key
  end

  def test_form_url
    expected = {
      controller: "admin/users",
      action: "update",
      id: @user.id
    }
    assert_equal expected, @facade.form_url
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Users", trail[1].text
    assert_equal "Edit", trail[2].text
  end
end
