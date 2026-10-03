require "test_helper"

class PlannedMeals::ReplaceRangeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @week = Date.new(2026, 10, 4)..Date.new(2026, 10, 10)
  end

  def test_replaces_only_the_given_dates
    @user.planned_meals.create!(date: Date.new(2026, 10, 5), recipe: recipes(:two))
    outside = @user.planned_meals.create!(date: Date.new(2026, 10, 11), recipe: recipes(:two))

    result = replace([
      { date: "2026-10-05", kind: "eat_out" },
      { date: "2026-10-05", recipe_id: recipes(:one).id },
      { date: "2026-10-06", recipe_id: recipes(:two).id }
    ])

    assert result.success?
    assert_equal [
      [ Date.new(2026, 10, 5), "eat_out", nil, 0 ],
      [ Date.new(2026, 10, 5), "recipe", recipes(:one).id, 1 ],
      [ Date.new(2026, 10, 6), "recipe", recipes(:two).id, 0 ]
    ], @user.planned_meals.where(date: @week).ordered.pluck(:date, :kind, :recipe_id, :position)
    assert PlannedMeal.exists?(outside.id)
  end

  def test_empty_entries_clear_the_range
    @user.planned_meals.create!(date: Date.new(2026, 10, 5), recipe: recipes(:two))

    assert replace([]).success?
    assert_empty @user.planned_meals.where(date: @week)
  end

  def test_rejects_entries_outside_the_range_and_changes_nothing
    existing = @user.planned_meals.create!(date: Date.new(2026, 10, 5), recipe: recipes(:two))

    result = replace([ { date: "2026-10-12", recipe_id: recipes(:two).id } ])

    assert_not result.success?
    assert_includes result.errors, "Every meal must fall within the dates being saved"
    assert PlannedMeal.exists?(existing.id)
  end

  def test_rejects_another_users_private_recipe
    result = PlannedMeals::ReplaceRange.call(user: users(:two), dates: @week,
      entries: [ { date: "2026-10-05", recipe_id: recipes(:one).id } ])

    assert_not result.success?
    assert_includes result.errors, "Recipe not found"
  end

  def test_rejects_ranges_longer_than_the_limit
    result = PlannedMeals::ReplaceRange.call(user: @user, dates: Date.new(2026, 1, 1)..Date.new(2026, 12, 31), entries: [])

    assert_not result.success?
  end

  private

  def replace(entries)
    PlannedMeals::ReplaceRange.call(user: @user, dates: @week, entries: entries)
  end
end
