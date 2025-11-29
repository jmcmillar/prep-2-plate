require "test_helper"

class Api::RecipeCategories::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @facade = Api::RecipeCategories::IndexFacade.new(@user, {})
  end

  def test_recipe_categories
    categories = @facade.recipe_categories
    
    assert_kind_of Array, categories
    assert categories.any?
    
    # Should have "My Recipes" as first item
    assert_equal "My Recipes", categories.first[:name]
  end
end
