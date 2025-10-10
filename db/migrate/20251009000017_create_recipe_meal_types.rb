class CreateRecipeMealTypes < ActiveRecord::Migration[7.2]
  def change
    create_table :recipe_meal_types do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :meal_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end