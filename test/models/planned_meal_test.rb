require "test_helper"

class PlannedMealTest < ActiveSupport::TestCase
  def test_recipe_entry_needs_a_recipe
    meal = users(:one).planned_meals.new(date: Date.current, kind: "recipe")

    assert_not meal.valid?
    assert_includes meal.errors[:recipe], "can't be blank"
  end

  def test_placeholder_entries_have_no_recipe
    assert users(:one).planned_meals.new(date: Date.current, kind: "eat_out").valid?

    meal = users(:one).planned_meals.new(date: Date.current, kind: "leftovers", recipe: recipes(:two))
    assert_not meal.valid?
  end

  def test_rejects_unknown_kinds
    assert_not users(:one).planned_meals.new(date: Date.current, kind: "brunch").valid?
  end

  def test_rejects_another_users_private_recipe
    meal = users(:two).planned_meals.new(date: Date.current, recipe: recipes(:one))

    assert_not meal.valid?
    assert_includes meal.errors[:recipe], "not found"
  end
end
