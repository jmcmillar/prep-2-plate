module ShoppingListItems
  class Archive
    include Service

    def initialize(shopping_list_item)
      @shopping_list_item = shopping_list_item
    end

    def call
      return false if @shopping_list_item.archived?

      @shopping_list_item.archive!
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Failed to archive shopping list item #{@shopping_list_item.id}: #{e.message}")
      false
    end
  end
end
