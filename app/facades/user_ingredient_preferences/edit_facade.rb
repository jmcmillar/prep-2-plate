class UserIngredientPreferences::EditFacade < UserIngredientPreferences::NewFacade
  def preference
    @preference ||= @user.user_ingredient_preferences.find(@params[:id])
  end

  def form_url
    {
      controller: "user_ingredient_preferences",
      action: "update",
      id: preference.id
    }
  end
end
