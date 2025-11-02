class Api::RecipeFavoritesController < Api::BaseController
  def index
    @facade = Api::RecipeFavorites::IndexFacade.new(current_user)
  end

  def create
    @facade = Api::RecipeFavorites::CreateFacade.new(current_user, params)
    @message = @facade.message

    if @facade.toggle_favorite
      render json: { message:  @message}, status: :ok
    else
      render json: @facade.resource.errors, status: :unprocessable_entity
    end
  end
end
