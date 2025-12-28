module UserIngredientPreferences
  class Create
    include Service

    def initialize(params)
      @params = params.is_a?(Hash) ? params.with_indifferent_access : params
    end

    def call
      preference = find_or_initialize_preference

      if preference.new_record?
        save_new_preference(preference)
      else
        update_existing_preference(preference)
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Failed to create/update preference: #{e.message}")
      false
    end

    private

    def find_or_initialize_preference
      UserIngredientPreference.find_or_initialize_by(
        user_id: @params[:user_id],
        ingredient_id: @params[:ingredient_id],
        packaging_form: normalize_value(@params[:packaging_form]),
        preparation_style: normalize_value(@params[:preparation_style])
      ) do |pref|
        pref.preferred_brand = @params[:preferred_brand]
      end
    end

    def save_new_preference(preference)
      if preference.save
        preference
      else
        false
      end
    end

    def update_existing_preference(preference)
      preference.preferred_brand = @params[:preferred_brand]

      if preference.save
        preference.record_usage!
        preference
      else
        false
      end
    end

    def normalize_value(value)
      value.presence
    end
  end
end
