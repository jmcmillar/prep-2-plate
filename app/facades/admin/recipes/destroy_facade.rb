class Admin::Recipes::DestroyFacade < Base::Admin::DestroyFacade
  def recipe
    @recipe ||= Recipe.find(@params[:id])
  end
end
