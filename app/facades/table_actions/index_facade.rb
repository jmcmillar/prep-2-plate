class TableActions::IndexFacade
  def initialize(user, params, request)
    @user = user
    @params = params
    @request = request
  end

  def action_collection
    Link::RowActions.to_data(
      id: @params[:id],
      label: @params[:label],
      controller: @params[:controller_path]
    )
  end
end
