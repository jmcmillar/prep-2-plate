class Admin::IngredientCategories::DestroyFacade < Base::Admin::DestroyFacade
  def ingredient_category
    @ingredient_category ||= IngredientCategory.find(@params[:id])
  end
end
