class Api::HomesController < Api::BaseController
  def show
    @facade = Api::Homes::ShowFacade.new(Current.user, params)
  end
end
