class CreateRecipeIngredients < ActiveRecord::Migration[7.2]
  def change
    create_table :recipe_ingredients do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.references :measurement_unit, null: true, foreign_key: true
      t.text :notes
      t.integer :numerator
      t.integer :denominator

      t.timestamps
    end

    # Add virtual column for quantity calculation
    add_column :recipe_ingredients, :quantity, :virtual, type: :decimal, 
               as: "CASE WHEN denominator != 0 THEN CAST(numerator AS DECIMAL) / CAST(denominator AS DECIMAL) ELSE NULL END", 
               stored: true
  end
end