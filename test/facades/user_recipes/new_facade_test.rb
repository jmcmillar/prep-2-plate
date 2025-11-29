require "test_helper"

class UserRecipes::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @facade = UserRecipes::NewFacade.new(@user, {})
  end

  def test_user_recipe_is_not_persisted
    assert @facade.user_recipe.new_record?
  end

  def test_user_recipe_has_built_recipe
    assert @facade.user_recipe.recipe.present?
    assert @facade.user_recipe.recipe.new_record?
  end

  def test_user_recipe_belongs_to_user
    assert_equal @user, @facade.user_recipe.user
  end

  def test_form_url
    assert_equal [@facade.user_recipe], @facade.form_url
  end

  def test_difficulty_levels
    levels = @facade.difficulty_levels
    
    assert_kind_of Array, levels
    assert levels.all? { |level| level.is_a?(UserRecipes::NewFacade::DifficultyLevel) }
  end

  def test_categories
    categories = @facade.categories
    
    assert_kind_of Array, categories
    assert categories.all? { |cat| cat.is_a?(RecipeCategory) }
  end

  def test_meal_types
    meal_types = @facade.meal_types
    
    assert_kind_of Array, meal_types
    assert meal_types.all? { |type| type.is_a?(MealType) }
  end
end
