class AddProductToShoppingListItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :shopping_list_items, :product, foreign_key: true, index: true
  end
end
