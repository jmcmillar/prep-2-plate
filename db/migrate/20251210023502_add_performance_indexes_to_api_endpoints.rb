class AddPerformanceIndexesToApiEndpoints < ActiveRecord::Migration[8.0]
  def change
    # Recipe queries - used in filtering and ordering
    add_index :recipes, :featured, if_not_exists: true
    add_index :recipes, :created_at, if_not_exists: true
    add_index :recipes, :duration_minutes, if_not_exists: true

    # Shopping lists - used to find current shopping list
    add_index :shopping_lists, :current, if_not_exists: true
    add_index :shopping_lists, [:user_id, :current], if_not_exists: true

    # Composite indexes for faster lookups and to prevent duplicates
    # Note: These will replace the single column indexes for better performance
    add_index :recipe_favorites, [:user_id, :recipe_id],
      unique: true,
      name: 'index_recipe_favorites_on_user_and_recipe',
      if_not_exists: true

    add_index :user_recipes, [:user_id, :recipe_id],
      unique: true,
      name: 'index_user_recipes_on_user_and_recipe',
      if_not_exists: true
  end
end
