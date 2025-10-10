class CreateMealPlans < ActiveRecord::Migration[7.2]
  def change
    create_table :meal_plans do |t|
      t.string :name
      t.text :description
      t.boolean :featured, default: false

      t.timestamps
    end
  end
end