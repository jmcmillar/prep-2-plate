class CreateUserShoppingItemPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :user_shopping_item_preferences do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :item_name, null: false
      t.string :preferred_brand, null: false
      t.integer :usage_count, null: false, default: 1
      t.datetime :last_used_at, null: false

      t.timestamps
    end

    # Composite unique index
    add_index :user_shopping_item_preferences,
              [:user_id, :item_name],
              unique: true,
              name: "idx_user_shopping_prefs_unique"

    # Analytics indexes
    add_index :user_shopping_item_preferences, :preferred_brand
    add_index :user_shopping_item_preferences, :last_used_at
    add_index :user_shopping_item_preferences, :created_at
  end
end
