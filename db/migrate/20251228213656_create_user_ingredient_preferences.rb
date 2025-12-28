class CreateUserIngredientPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :user_ingredient_preferences do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :ingredient, null: false, foreign_key: true, index: true
      t.string :packaging_form      # Optional - allows generic preferences
      t.string :preparation_style   # Optional - allows generic preferences
      t.string :preferred_brand, null: false
      t.integer :usage_count, default: 1, null: false
      t.datetime :last_used_at, null: false

      t.timestamps
    end

    # Composite unique index to ensure one preference per user/ingredient/packaging/prep combination
    add_index :user_ingredient_preferences,
              [:user_id, :ingredient_id, :packaging_form, :preparation_style],
              unique: true,
              name: "index_user_ingredient_prefs_on_user_ingredient_packaging_prep"
  end
end
