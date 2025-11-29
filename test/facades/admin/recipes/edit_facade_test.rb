require "test_helper"

class Admin::Recipes::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @recipe = recipes(:one)
    @facade = Admin::Recipes::EditFacade.new(@admin, { id: @recipe.id })
  end

  def test_recipe
    assert_equal @recipe, @facade.recipe
  end

  def test_active_key
    assert_equal :admin_recipes, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 4, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Recipes", trail[1].text
    assert_equal "Edit", trail[3].text
  end

  def test_form_url
    assert_equal [:admin, @recipe], @facade.form_url
  end

  def test_difficulty_levels
    levels = @facade.difficulty_levels
    
    assert_kind_of Array, levels
    assert levels.length > 0
  end

  def test_categories
    categories = @facade.categories
    
    assert_kind_of ActiveRecord::Relation, categories
  end

  def test_meal_types
    meal_types = @facade.meal_types
    
    assert_kind_of ActiveRecord::Relation, meal_types
  end
end
