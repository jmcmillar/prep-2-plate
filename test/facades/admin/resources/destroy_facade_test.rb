require "test_helper"

class Admin::Resources::DestroyFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @resource = resources(:one)
    @facade = Admin::Resources::DestroyFacade.new(@admin, { id: @resource.id })
  end

  def test_resource
    assert_equal @resource, @facade.resource
  end
end
