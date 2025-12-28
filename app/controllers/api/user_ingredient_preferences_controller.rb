class Api::UserIngredientPreferencesController < Api::BaseController
  def index
    @preferences = Current.user.user_ingredient_preferences
                              .includes(:ingredient)
                              .order(last_used_at: :desc)
  end

  def show
    @preference = Current.user.user_ingredient_preferences.find(params[:id])
  end

  def create
    result = UserIngredientPreferences::Create.call(
      preference_params.merge(user_id: Current.user.id)
    )

    if result.is_a?(UserIngredientPreference)
      @preference = result
      render :show, status: :created
    else
      render json: { errors: ["Failed to create preference"] }, status: :unprocessable_entity
    end
  end

  def update
    preference = Current.user.user_ingredient_preferences.find(params[:id])

    result = UserIngredientPreferences::Create.call(
      preference_params.merge(
        user_id: Current.user.id,
        ingredient_id: preference.ingredient_id
      )
    )

    if result.is_a?(UserIngredientPreference)
      @preference = result
      render :show, status: :ok
    else
      render json: { errors: ["Failed to update preference"] }, status: :unprocessable_entity
    end
  end

  def destroy
    preference = Current.user.user_ingredient_preferences.find(params[:id])

    if preference.destroy
      head :no_content
    else
      render json: { errors: preference.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def suggest
    if params[:ingredient_id].blank?
      render json: { error: "ingredient_id is required" }, status: :bad_request
      return
    end

    preference = UserIngredientPreference.find_best_match(
      Current.user.id,
      params[:ingredient_id],
      params[:packaging_form],
      params[:preparation_style]
    )

    if preference
      render json: {
        preferred_brand: preference.preferred_brand,
        packaging_form: preference.packaging_form,
        preparation_style: preference.preparation_style,
        usage_count: preference.usage_count
      }
    else
      head :no_content
    end
  end

  private

  def preference_params
    params.require(:user_ingredient_preference).permit(
      :ingredient_id,
      :packaging_form,
      :preparation_style,
      :preferred_brand
    )
  end
end
