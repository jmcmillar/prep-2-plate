class Admin::Ingredients::DestroyFacade < Base::Admin::DestroyFacade
  def ingredient
    @ingredient ||= Ingredient.find(@params[:id])
  end
end
