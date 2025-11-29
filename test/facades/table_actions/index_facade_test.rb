require "test_helper"

class TableActions::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @request = ActionDispatch::TestRequest.create
    @facade = TableActions::IndexFacade.new(
      @user, 
      { id: 1, label: "Test", controller_path: "recipes" },
      @request
    )
  end

  def test_action_collection
    actions = @facade.action_collection
    
    assert_kind_of Array, actions
  end
end
