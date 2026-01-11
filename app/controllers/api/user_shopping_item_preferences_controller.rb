class Api::UserShoppingItemPreferencesController < Api::BaseController
  def index
    @preferences = Current.user.user_shopping_item_preferences
                              .order(last_used_at: :desc)
  end

  def show
    @preference = Current.user.user_shopping_item_preferences.find(params[:id])
  end

  def create
    result = UserShoppingItemPreferences::Create.call(
      preference_params.merge(user_id: Current.user.id)
    )

    if result.is_a?(UserShoppingItemPreference)
      @preference = result
      render :show, status: :created
    else
      render json: { errors: ["Failed to create preference"] }, status: :unprocessable_entity
    end
  end

  def update
    preference = Current.user.user_shopping_item_preferences.find(params[:id])

    result = UserShoppingItemPreferences::Create.call(
      preference_params.merge(user_id: Current.user.id)
    )

    if result.is_a?(UserShoppingItemPreference)
      @preference = result
      render :show, status: :ok
    else
      render json: { errors: ["Failed to update preference"] }, status: :unprocessable_entity
    end
  end

  def destroy
    preference = Current.user.user_shopping_item_preferences.find(params[:id])

    if preference.destroy
      head :no_content
    else
      render json: { errors: preference.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def suggest
    if params[:item_name].blank?
      render json: { error: "item_name is required" }, status: :bad_request
      return
    end

    preference = UserShoppingItemPreference.find_for_item(
      Current.user.id,
      params[:item_name]
    )

    if preference
      render json: {
        preferred_brand: preference.preferred_brand,
        usage_count: preference.usage_count
      }
    else
      head :no_content
    end
  end

  private

  def preference_params
    params.require(:user_shopping_item_preference).permit(
      :item_name,
      :preferred_brand
    )
  end
end
