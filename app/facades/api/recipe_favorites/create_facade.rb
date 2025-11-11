class Api::RecipeFavorites::CreateFacade
  def initialize(user, params)
    @user = user
    @params = params
  end

  def toggle_favorite
    if favorite
      favorite.destroy
    else
      @user.recipe_favorites.create(recipe_id: recipe_id)
    end
  end

  def message
    if favorite
      "Recipe removed from favorites"
    else
      "Recipe added to favorites"
    end
  end

  private

  def favorite
    @favorite ||= @user.recipe_favorites.find_by(recipe_id: recipe_id)
  end

  def recipe_id
    @params[:recipe_id]
  end
end
