# Copies each user's saved meal plans into their planner calendar. When
# several saved plans cover the same day, the most recently saved one wins,
# matching what the app showed (it loaded the latest plan).
class BackfillPlannedMealsFromSavedMealPlans < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      INSERT INTO planned_meals (user_id, recipe_id, date, kind, position, created_at, updated_at)
      SELECT user_id, recipe_id, date, 'recipe',
             ROW_NUMBER() OVER (PARTITION BY user_id, date ORDER BY meal_plan_recipe_id) - 1,
             NOW(), NOW()
      FROM (
        SELECT user_meal_plans.user_id, meal_plan_recipes.recipe_id, meal_plan_recipes.date,
               meal_plan_recipes.id AS meal_plan_recipe_id,
               RANK() OVER (
                 PARTITION BY user_meal_plans.user_id, meal_plan_recipes.date
                 ORDER BY user_meal_plans.created_at DESC, user_meal_plans.id DESC
               ) AS plan_rank
        FROM meal_plan_recipes
        JOIN user_meal_plans ON user_meal_plans.meal_plan_id = meal_plan_recipes.meal_plan_id
        WHERE meal_plan_recipes.date IS NOT NULL
      ) ranked
      WHERE plan_rank = 1
    SQL
  end

  def down
    # Saved meal plans are untouched; the copied rows go with the table
  end
end
