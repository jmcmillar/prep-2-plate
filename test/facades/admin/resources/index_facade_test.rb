require "test_helper"

class Admin::Resources::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @resource = Resource.create!(name: "Test Resource", description: "Test description")
    @facade = Admin::Resources::IndexFacade.new(@user, {})
  end

  def test_active_key
    assert_equal :admin_resources, @facade.active_key
  end

  def test_base_collection
    assert_includes @facade.base_collection, @resource
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 2, trail.length
    assert_equal "Admin", trail.first.text
    assert_equal "Resources", trail.last.text
  end

  def test_search_data
    search_data = @facade.search_data
    
    assert_kind_of SearchFormComponent::Data, search_data
    assert_equal "Search Name", search_data.label
  end

  def test_new_action_data
    action = @facade.new_action_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal "New Resource", action.label
  end
end
