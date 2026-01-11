module UserShoppingItemPreferences
  class Create
    include Service

    def initialize(params)
      @params = params
    end

    def call
      preference = UserShoppingItemPreference.find_for_item(
        @params[:user_id],
        @params[:item_name]
      )

      if preference
        # Update existing preference
        preference.update(preferred_brand: @params[:preferred_brand])
        preference.record_usage!
        preference
      else
        # Create new preference
        UserShoppingItemPreference.create(@params)
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Failed to create shopping item preference: #{e.message}")
      nil
    end
  end
end
