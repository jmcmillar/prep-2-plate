class Api::RecipeFavorites::IndexFacade
  def initialize(user, params = {})
    @user = user
    @params = params
  end

  def favorite_recipes
    @user.recipes.with_attached_image
  end

  def imported_recipes
    base_user_recipes.imported
  end

  def user_recipes
    base_user_recipes.where(recipe_import_id: nil)
  end

  private

  def base_user_recipes
    @user_recipes ||= Recipe.joins(:user_recipe).where(user_recipes: { user: @user }).order(created_at: :desc).with_attached_image
  end
end
