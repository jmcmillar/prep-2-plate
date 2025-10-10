class CreateShoppingLists < ActiveRecord::Migration[7.2]
  def change
    create_table :shopping_lists do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true
      t.boolean :current, default: false, null: false

      t.timestamps
    end
  end
end