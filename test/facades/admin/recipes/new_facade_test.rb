require "test_helper"

class Admin::Recipes::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @facade = Admin::Recipes::NewFacade.new(@admin, {})
  end

  def test_recipe
    recipe = @facade.recipe
    
    assert_kind_of Recipe, recipe
    assert recipe.new_record?
  end

  def test_active_key
    assert_equal :admin_recipes, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Recipes", trail[1].text
    assert_equal "New", trail[2].text
  end

  def test_form_url
    recipe = @facade.recipe
    assert_equal [:admin, recipe], @facade.form_url
  end

  def test_difficulty_levels
    levels = @facade.difficulty_levels
    
    assert_kind_of Array, levels
    assert levels.length > 0
  end

  def test_categories
    categories = @facade.categories
    
    assert_kind_of Array, categories
  end

  def test_meal_types
    meal_types = @facade.meal_types
    
    assert_kind_of Array, meal_types
  end
end
