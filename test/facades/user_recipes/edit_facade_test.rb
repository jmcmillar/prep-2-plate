require "test_helper"

class UserRecipes::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @user_recipe = user_recipes(:one)
    @facade = UserRecipes::EditFacade.new(@user, { id: @user_recipe.id })
  end

  def test_user_recipe
    assert_equal @user_recipe, @facade.user_recipe
  end

  def test_recipe
    assert_equal @user_recipe.recipe, @facade.recipe
  end

  def test_form_url
    assert_equal [@user_recipe], @facade.form_url
  end

  def test_difficulty_levels
    levels = @facade.difficulty_levels
    
    assert_kind_of Array, levels
    assert levels.all? { |level| level.is_a?(UserRecipes::EditFacade::DifficultyLevel) }
  end

  def test_categories
    categories = @facade.categories
    
    assert_kind_of ActiveRecord::Relation, categories
    assert categories.all? { |cat| cat.is_a?(RecipeCategory) }
  end

  def test_meal_types
    meal_types = @facade.meal_types
    
    assert_kind_of ActiveRecord::Relation, meal_types
    assert meal_types.all? { |type| type.is_a?(MealType) }
  end

  def test_ingredients
    ingredients = @facade.ingredients
    
    assert_kind_of ActiveRecord::Relation, ingredients
    assert ingredients.all? { |ing| ing.is_a?(Ingredient) }
  end

  def test_measurement_units
    units = @facade.measurement_units
    
    assert_kind_of ActiveRecord::Relation, units
    assert units.all? { |unit| unit.is_a?(MeasurementUnit) }
  end
end
