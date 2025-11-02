class RecipeFavorites::DestroyFacade < BaseFacade
  def recipe_favorite
    @recipe_favorite ||= RecipeFavorite.find(@params[:id])
  end

  def recipe
    @recipe ||= recipe_favorite.recipe
  end
end
