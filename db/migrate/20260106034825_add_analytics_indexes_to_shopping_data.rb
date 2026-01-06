class AddAnalyticsIndexesToShoppingData < ActiveRecord::Migration[8.0]
  def change
    # Indexes for shopping_list_items analytics queries
    add_index :shopping_list_items, :archived_at unless index_exists?(:shopping_list_items, :archived_at)
    add_index :shopping_list_items, :created_at unless index_exists?(:shopping_list_items, :created_at)
    add_index :shopping_list_items, :packaging_form unless index_exists?(:shopping_list_items, :packaging_form)
    add_index :shopping_list_items, :preparation_style unless index_exists?(:shopping_list_items, :preparation_style)

    # Indexes for shopping_lists analytics queries
    add_index :shopping_lists, :created_at unless index_exists?(:shopping_lists, :created_at)

    # Indexes for user_ingredient_preferences analytics queries
    add_index :user_ingredient_preferences, :usage_count unless index_exists?(:user_ingredient_preferences, :usage_count)
    add_index :user_ingredient_preferences, :last_used_at unless index_exists?(:user_ingredient_preferences, :last_used_at)
    add_index :user_ingredient_preferences, :created_at unless index_exists?(:user_ingredient_preferences, :created_at)
    add_index :user_ingredient_preferences, :preferred_brand unless index_exists?(:user_ingredient_preferences, :preferred_brand)
    add_index :user_ingredient_preferences, :packaging_form unless index_exists?(:user_ingredient_preferences, :packaging_form)
    add_index :user_ingredient_preferences, :preparation_style unless index_exists?(:user_ingredient_preferences, :preparation_style)
  end
end
