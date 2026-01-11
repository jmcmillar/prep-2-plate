module UserShoppingItemPreferences
  class ApplyToItem
    include Service

    def initialize(shopping_list_item)
      @item = shopping_list_item
    end

    def call
      return false unless valid_for_applying?

      preference = find_preference

      if preference.present?
        @item.brand = preference.preferred_brand
        true
      else
        false
      end
    end

    private

    def valid_for_applying?
      @item.ingredient_id.blank? &&  # Only for NON-ingredient items
        @item.name.present? &&
        @item.brand.blank? &&
        user.present?
    end

    def find_preference
      UserShoppingItemPreference.find_for_item(user.id, @item.name)
    end

    def user
      @user ||= @item.shopping_list&.user
    end
  end
end
