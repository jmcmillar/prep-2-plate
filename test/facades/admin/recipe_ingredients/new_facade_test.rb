require "test_helper"

class Admin::RecipeIngredients::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @recipe = recipes(:one)
    @facade = Admin::RecipeIngredients::NewFacade.new(@admin, { recipe_id: @recipe.id })
  end

  def test_recipe_ingredient
    ingredient = @facade.recipe_ingredient
    
    assert_kind_of RecipeIngredient, ingredient
    assert ingredient.new_record?
  end

  def test_recipe
    assert_equal @recipe, @facade.recipe
  end

  def test_active_key
    assert_equal :admin_recipes, @facade.active_key
  end

  def test_measurement_units
    units = @facade.measurement_units
    
    assert_kind_of ActiveRecord::Relation, units
  end

  def test_ingredients
    ingredients = @facade.ingredients
    
    assert_kind_of ActiveRecord::Relation, ingredients
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Recipe Ingredients", trail[1].text
    assert_equal "New", trail[2].text
  end

  def test_form_url
    assert_equal [:admin, @recipe, :recipe_ingredients], @facade.form_url
  end
end
