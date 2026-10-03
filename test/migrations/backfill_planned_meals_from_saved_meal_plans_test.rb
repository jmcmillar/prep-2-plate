require "test_helper"
require Rails.root.join("db/migrate/20261003120100_backfill_planned_meals_from_saved_meal_plans")

class BackfillPlannedMealsFromSavedMealPlansTest < ActiveSupport::TestCase
  def setup
    PlannedMeal.delete_all
    MealPlanRecipe.delete_all
    UserMealPlan.delete_all
    @user = users(:two)
  end

  def test_most_recently_saved_plan_wins_for_each_day
    older = save_plan(2.days.ago, "2026-10-05" => [ recipes(:two) ], "2026-10-06" => [ recipes(:two) ])
    newer = save_plan(Time.current, "2026-10-06" => [ recipes(:destroyable), recipes(:two) ])

    ActiveRecord::Migration.suppress_messages { BackfillPlannedMealsFromSavedMealPlans.new.up }

    assert_equal [
      [ Date.new(2026, 10, 5), recipes(:two).id, 0 ],
      [ Date.new(2026, 10, 6), recipes(:destroyable).id, 0 ],
      [ Date.new(2026, 10, 6), recipes(:two).id, 1 ]
    ], @user.planned_meals.ordered.pluck(:date, :recipe_id, :position)
    assert @user.planned_meals.all?(&:recipe_kind?)
    assert older.persisted? && newer.persisted?
  end

  private

  def save_plan(saved_at, recipes_by_date)
    meal_plan = MealPlan.create!(name: "Plan #{SecureRandom.hex(4)}")
    recipes_by_date.each do |date, recipes|
      recipes.each { |recipe| meal_plan.meal_plan_recipes.create!(recipe: recipe, date: date) }
    end
    @user.user_meal_plans.create!(meal_plan: meal_plan, created_at: saved_at)
  end
end
