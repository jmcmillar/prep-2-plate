class CreateOfferingMealTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :offering_meal_types do |t|
      t.references :offering, null: false, foreign_key: true
      t.references :meal_type, null: false, foreign_key: true

      t.timestamps
    end

    add_index :offering_meal_types, [:offering_id, :meal_type_id], unique: true
  end
end
