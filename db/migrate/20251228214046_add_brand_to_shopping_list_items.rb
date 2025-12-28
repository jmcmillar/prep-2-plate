class AddBrandToShoppingListItems < ActiveRecord::Migration[8.0]
  def change
    add_column :shopping_list_items, :brand, :string
    add_index :shopping_list_items, :brand
  end
end
