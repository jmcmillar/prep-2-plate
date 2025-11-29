require "test_helper"

class Api::RecipeCategories::ShowFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe_category = recipe_categories(:one)
    @facade = Api::RecipeCategories::ShowFacade.new(@user, { id: @recipe_category.id })
  end

  def test_recipe_category
    assert_equal @recipe_category, @facade.recipe_category
  end

  def test_recipes
    recipes = @facade.recipes
    
    assert_kind_of ActiveRecord::Relation, recipes
  end

  def test_base_recipes_with_category
    recipes = @facade.base_recipes
    
    assert_kind_of ActiveRecord::Relation, recipes
  end

  def test_base_recipes_without_category
    facade = Api::RecipeCategories::ShowFacade.new(@user, { id: nil })
    recipes = facade.base_recipes
    
    assert_kind_of ActiveRecord::Relation, recipes
  end
end
