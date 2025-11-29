require "test_helper"

class Admin::MealPlanRecipes::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @meal_plan = meal_plans(:one)
    @recipe = recipes(:one)
    @meal_plan_recipe = @meal_plan.meal_plan_recipes.create!(
      recipe: @recipe,
      date: Date.today
    )
    @facade = Admin::MealPlanRecipes::IndexFacade.new(@admin, { meal_plan_id: @meal_plan.id })
  end

  def test_meal_plan
    assert_equal @meal_plan, @facade.meal_plan
  end

  def test_base_collection
    assert_includes @facade.base_collection, @meal_plan_recipe
  end

  def test_calendar_events
    events = @facade.calendar_events
    
    assert_kind_of Array, events
    assert events.length > 0
    assert_equal @meal_plan_recipe.id, events.first[:id]
    assert_equal @recipe.name, events.first[:title]
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 2, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Meal Plan Recipes", trail[1].text
  end

  def test_new_action_data
    action = @facade.new_action_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal "New Recipe Ingredient", action.label
  end

  def test_resource_facade_class
    assert_equal Admin::MealPlanRecipes::ResourceFacade, @facade.resource_facade_class
  end
end
