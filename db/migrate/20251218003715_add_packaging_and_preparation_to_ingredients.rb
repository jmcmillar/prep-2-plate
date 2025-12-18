class AddPackagingAndPreparationToIngredients < ActiveRecord::Migration[8.0]
  def change
    add_column :ingredients, :packaging_form, :string
    add_column :ingredients, :preparation_style, :string

    # Add composite index for future uniqueness constraint
    add_index :ingredients,
              [:name, :packaging_form, :preparation_style],
              unique: true,
              name: 'idx_ingredients_on_name_packaging_prep'
  end
end
