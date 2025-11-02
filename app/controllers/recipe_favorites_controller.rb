class RecipeFavoritesController < AuthenticatedController
  layout "application"
  def create
    @facade = RecipeFavorites::NewFacade.new(Current.user, params)
    if @facade.recipe_favorite.save
      redirect_to recipe_path(@facade.recipe), notice: "Recipe added to favorites."
    else
      render :new
    end
  end

  def destroy
    @facade = RecipeFavorites::DestroyFacade.new(Current.user, params)
    if @facade.recipe_favorite.destroy
      redirect_to recipe_path(@facade.recipe), notice: "Recipe removed from favorites."
    else
      render :index
    end
  end

  private

  def recipe_favorite_params
    params.require(:recipe_favorite).permit(:recipe_id)
  end
end
