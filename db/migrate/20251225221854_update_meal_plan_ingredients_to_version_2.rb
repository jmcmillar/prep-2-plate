class UpdateMealPlanIngredientsToVersion2 < ActiveRecord::Migration[8.0]
  def change
    update_view :meal_plan_ingredients, version: 2, revert_to_version: 1
  end
end
