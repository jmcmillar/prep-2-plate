class CreatePlannedMeals < ActiveRecord::Migration[8.0]
  def change
    create_table :planned_meals do |t|
      t.references :user, null: false, foreign_key: true
      t.references :recipe, foreign_key: true
      t.date :date, null: false
      t.string :kind, null: false, default: "recipe"
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :planned_meals, [ :user_id, :date ]
  end
end
