class TableActionsController < Authenticated::BaseController
  def index
    @facade = TableActions::IndexFacade.new current_user, params, request
  end
end
