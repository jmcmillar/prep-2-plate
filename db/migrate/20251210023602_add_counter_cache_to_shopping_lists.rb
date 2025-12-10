class AddCounterCacheToShoppingLists < ActiveRecord::Migration[8.0]
  def change
    add_column :shopping_lists, :shopping_list_items_count, :integer, default: 0, null: false

    # Backfill existing counts
    reversible do |dir|
      dir.up do
        ShoppingList.find_each do |list|
          ShoppingList.reset_counters(list.id, :shopping_list_items)
        end
      end
    end
  end
end
