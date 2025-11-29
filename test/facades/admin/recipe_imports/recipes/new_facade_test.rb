require "test_helper"

class Admin::RecipeImports::Recipes::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @recipe_import = RecipeImport.create!(url: "https://example.com/recipe")
    @facade = Admin::RecipeImports::Recipes::NewFacade.new(@admin, { recipe_import_id: @recipe_import.id })
  end

  def test_active_key
    assert_equal :admin_recipes, @facade.active_key
  end

  def test_import_record
    assert_equal @recipe_import, @facade.import_record
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Recipes", trail[1].text
    assert_equal "Import Recipe", trail[2].text
  end

  def test_form_url
    assert_equal [:admin, @recipe_import, :recipes], @facade.form_url
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
