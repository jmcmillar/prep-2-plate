# Whether an item's brand is one of the user's saved brand preferences, and
# forgetting it. Loads the user's preferences once, so one instance can serve
# a whole list. Uses the same keys the Learn services save under.
module ShoppingListItems
  class BrandMemory
    def initialize(user)
      @user = user
    end

    def remembered?(item)
      item.brand.present? && preference_for(item)&.preferred_brand.to_s.casecmp?(item.brand)
    end

    # Stops the item's current brand from being applied to new items
    def forget(item)
      return unless remembered?(item)

      preference_for(item).destroy
      @ingredient_preferences = @item_preferences = nil
    end

    private

    def preference_for(item)
      if item.ingredient_id
        ingredient_preferences[ingredient_key(item.ingredient_id, item.packaging_form, item.preparation_style)]
      else
        item_preferences[item.name.to_s.downcase.strip]
      end
    end

    def ingredient_preferences
      @ingredient_preferences ||= UserIngredientPreference.where(user: @user).index_by do |preference|
        ingredient_key(preference.ingredient_id, preference.packaging_form, preference.preparation_style)
      end
    end

    def item_preferences
      @item_preferences ||= UserShoppingItemPreference.where(user: @user).index_by(&:item_name)
    end

    def ingredient_key(ingredient_id, packaging_form, preparation_style)
      [ ingredient_id, packaging_form.presence, preparation_style.presence ]
    end
  end
end
