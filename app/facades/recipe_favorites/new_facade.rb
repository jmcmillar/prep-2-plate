class RecipeFavorites::NewFacade < BaseFacade
  def recipe
    @recipe ||= Recipe.find(params[:recipe_id])
  end

  def recipe_favorite
    @recipe_favorite ||= RecipeFavorite.new(user: @user, recipe: recipe)
  end
end
