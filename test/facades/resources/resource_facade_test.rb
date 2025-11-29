require "test_helper"

class Resources::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    @resource = resources(:one)
    @facade = Resources::ResourceFacade.new(@resource)
  end

  def test_resource_returns_resource_record
    assert_equal @resource, @facade.resource
  end

  def test_row_id_returns_formatted_string
    assert_equal "resource_#{@resource.id}", @facade.row_id
  end

  def test_id_returns_resource_id
    assert_equal @resource.id, @facade.id
  end
end
