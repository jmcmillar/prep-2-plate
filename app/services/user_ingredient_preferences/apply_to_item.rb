module UserIngredientPreferences
  class ApplyToItem
    include Service

    def initialize(shopping_list_item)
      @item = shopping_list_item
    end

    def call
      return false unless valid_for_applying?

      preference = find_best_match

      if preference.present?
        @item.brand = preference.preferred_brand
        true
      else
        false
      end
    end

    private

    def valid_for_applying?
      @item.ingredient_id.present? &&
        @item.brand.blank? &&
        user.present?
    end

    def find_best_match
      UserIngredientPreference.find_best_match(
        user.id,
        @item.ingredient_id,
        @item.packaging_form,
        @item.preparation_style
      )
    end

    def user
      @user ||= @item.shopping_list&.user
    end
  end
end
