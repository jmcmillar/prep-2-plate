class UserIngredientPreferencesController < AuthenticatedController
  layout "application"

  def index
    @facade = UserIngredientPreferences::IndexFacade.new(Current.user, params)
  end

  def new
    @facade = UserIngredientPreferences::NewFacade.new(Current.user, params)
  end

  def create
    result = UserIngredientPreferences::Create.call(
      user_ingredient_preference_params.merge(user_id: Current.user.id)
    )

    if result
      redirect_to user_ingredient_preferences_path, notice: "Preference was successfully created."
    else
      @facade = UserIngredientPreferences::NewFacade.new(Current.user, params)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @facade = UserIngredientPreferences::EditFacade.new(Current.user, params)
  end

  def update
    result = UserIngredientPreferences::Create.call(
      user_ingredient_preference_params.merge(
        user_id: Current.user.id,
        ingredient_id: @facade.preference.ingredient_id
      )
    )

    if result
      redirect_to user_ingredient_preferences_path, notice: "Preference was successfully updated."
    else
      @facade = UserIngredientPreferences::EditFacade.new(Current.user, params)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    preference = Current.user.user_ingredient_preferences.find(params[:id])
    preference.destroy
    redirect_to user_ingredient_preferences_path, notice: "Preference was successfully deleted."
  end

  private

  def user_ingredient_preference_params
    params.require(:user_ingredient_preference).permit(
      :ingredient_id,
      :packaging_form,
      :preparation_style,
      :preferred_brand
    )
  end
end
