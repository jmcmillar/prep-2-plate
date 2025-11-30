class AddCategoryToIngredients < ActiveRecord::Migration[8.0]
  def change
    add_reference :ingredients, :ingredient_category, null: true, foreign_key: true
    add_column :ingredients, :categorized_by, :string
    add_column :ingredients, :categorized_at, :datetime
  end
end
