class Api::RecipeIngredients::IndexFacade
  def initialize(user, params)
    @user = user
    @params = params
  end

  def current_shopping_list_id
    @user.shopping_lists.where(current: true)&.first&.id || nil
  end

  def recipe_ingredients
    RecipeIngredient::FullNameDecorator.decorate_collection(RecipeIngredient.includes(:recipe).where(recipe: {id:  @params[:recipe_ids]}).order(:name))
  end
end
