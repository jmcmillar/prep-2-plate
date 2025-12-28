module UserIngredientPreferences
  class Learn
    include Service

    def initialize(shopping_list_item)
      @item = shopping_list_item
    end

    def call
      return false unless valid_for_learning?

      preference = find_or_initialize_preference

      if preference.new_record?
        preference.save
      else
        preference.record_usage!
        true
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Failed to learn preference from shopping list item #{@item.id}: #{e.message}")
      false
    end

    private

    def valid_for_learning?
      @item.ingredient_id.present? &&
        @item.brand.present? &&
        user.present?
    end

    def find_or_initialize_preference
      UserIngredientPreference.find_or_initialize_by(
        user: user,
        ingredient_id: @item.ingredient_id,
        packaging_form: @item.packaging_form,
        preparation_style: @item.preparation_style
      ) do |pref|
        pref.preferred_brand = @item.brand
      end
    end

    def user
      @user ||= @item.shopping_list&.user
    end
  end
end
