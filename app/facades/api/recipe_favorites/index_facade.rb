class Api::RecipeFavorites::IndexFacade
  def initialize(user, params = {})
    @user = user
    @params = params
  end

  def favorite_recipes
    search(@user.recipes.visible_to(@user).with_attached_image)
  end

  def imported_recipes
    search(base_user_recipes.imported)
  end

  def user_recipes
    search(base_user_recipes.where(recipe_import_id: nil))
  end

  private

  def base_user_recipes
    @user_recipes ||= Recipe.joins(:user_recipe).where(user_recipes: { user: @user }).order(created_at: :desc).with_attached_image.includes(:recipe_import)
  end

  # Applies the same q[name_cont] search to every section
  def search(recipes)
    recipes.ransack(@params[:q]).result
  end
end
