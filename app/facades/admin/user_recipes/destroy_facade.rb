class Admin::UserRecipes::DestroyFacade < Base::Admin::DestroyFacade
  def user_recipe
    @user_recipe ||= UserRecipe.find(@params[:id])
  end
end
