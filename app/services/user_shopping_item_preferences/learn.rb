module UserShoppingItemPreferences
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
        # Update brand preference and record usage
        preference.save
        preference.increment!(:usage_count)
        true
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Failed to learn shopping item preference from item #{@item.id}: #{e.message}")
      false
    end

    private

    def valid_for_learning?
      @item.ingredient_id.blank? &&  # Only for NON-ingredient items
        @item.name.present? &&
        @item.brand.present? &&
        user.present?
    end

    def find_or_initialize_preference
      existing = UserShoppingItemPreference.find_for_item(user.id, @item.name)

      if existing
        existing.preferred_brand = @item.brand
        existing.last_used_at = Time.current
        existing
      else
        UserShoppingItemPreference.new(
          user: user,
          item_name: @item.name.downcase.strip,
          preferred_brand: @item.brand,
          last_used_at: Time.current
        )
      end
    end

    def user
      @user ||= @item.shopping_list&.user
    end
  end
end
