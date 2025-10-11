class Admin::RecipeIngredients::DestroyFacade < Base::Admin::DestroyFacade
  def recipe_ingredient
    @recipe_ingredient ||= RecipeIngredient.find(@params[:id])
  end
end
