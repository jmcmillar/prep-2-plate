class CreateShoppingListItems < ActiveRecord::Migration[7.2]
  def change
    create_table :shopping_list_items do |t|
      t.string :name
      t.references :shopping_list, null: false, foreign_key: true

      t.timestamps
    end
  end
end