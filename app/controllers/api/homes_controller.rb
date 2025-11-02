class Api::HomesController < Api::BaseController
  def show
    @facade = Api::Homes::ShowFacade.new(current_user, params)
  end
end
