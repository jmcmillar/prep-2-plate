class CreateMealPlanIngredients < ActiveRecord::Migration[8.0]
  def change
    create_view :meal_plan_ingredients
  end
end
