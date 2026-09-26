class AddTrigramNameIndexes < ActiveRecord::Migration[8.0]
  def change
    enable_extension "pg_trgm"

    add_index :recipes, "lower(name) gin_trgm_ops", using: :gin, name: "index_recipes_on_lower_name_trgm"
    add_index :ingredients, "lower(name) gin_trgm_ops", using: :gin, name: "index_ingredients_on_lower_name_trgm"
  end
end
