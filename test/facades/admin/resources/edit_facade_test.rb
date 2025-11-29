require "test_helper"

class Admin::Resources::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @resource = Resource.create!(name: "Test Resource", description: "Test description")
    @facade = Admin::Resources::EditFacade.new(@user, { id: @resource.id })
  end

  def test_resource
    assert_equal @resource, @facade.resource
  end

  def test_active_key
    assert_equal :admin_resources, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Resources", trail[1].text
    assert_equal "Edit", trail[2].text
  end
end
