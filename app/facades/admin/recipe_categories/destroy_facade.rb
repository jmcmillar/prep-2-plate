class Admin::RecipeCategories::DestroyFacade < Base::Admin::DestroyFacade
  def recipe_category
    @recipe_category ||= RecipeCategory.find(@params[:id])
  end
end
