class TableActionsController < AuthenticatedController
  def index
    @facade = TableActions::IndexFacade.new Current.user, params, request
  end
end
