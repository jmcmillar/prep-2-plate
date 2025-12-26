class AddPackagingAndPreparationToShoppingListItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :shopping_list_items, :ingredient, foreign_key: true, index: true
    add_column :shopping_list_items, :packaging_form, :string
    add_column :shopping_list_items, :preparation_style, :string

    # Add composite index for efficient queries
    add_index :shopping_list_items,
              [:shopping_list_id, :ingredient_id, :packaging_form, :preparation_style],
              name: "idx_shopping_list_items_unique_ingredient"
  end
end
