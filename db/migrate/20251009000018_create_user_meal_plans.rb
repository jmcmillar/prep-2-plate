class CreateUserMealPlans < ActiveRecord::Migration[7.2]
  def change
    create_table :user_meal_plans do |t|
      t.references :user, null: false, foreign_key: true
      t.references :meal_plan, null: false, foreign_key: true

      t.timestamps
    end
  end
end