class AddArchivingToShoppingListItems < ActiveRecord::Migration[8.0]
  def change
    add_column :shopping_list_items, :archived_at, :datetime
    add_index :shopping_list_items, :archived_at

    # Recalculate counter cache to exclude archived items
    reversible do |dir|
      dir.up do
        ShoppingList.find_each do |list|
          ShoppingList.reset_counters(list.id, :shopping_list_items)
        end
      end
    end
  end
end
