require "test_helper"

class MealPlanner::Recipes::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @facade = MealPlanner::Recipes::IndexFacade.new(@user, {})
  end

  def test_base_collection
    assert_includes @facade.base_collection, @recipe
  end

  def test_collection
    assert_kind_of CollectionBuilder, @facade.collection
  end

  def test_search_data
    search_data = @facade.search_data
    
    assert_kind_of SearchFormComponent::Data, search_data
    assert_equal "Search Name, Meal Types, Categories", search_data.label
  end

  def test_meal_type_filter_data
    filter_data = @facade.meal_type_filter_data
    
    assert_kind_of FilterComponent::Data, filter_data
    assert_equal "Meal Types", filter_data.title
  end

  def test_recipe_category_filter_data
    filter_data = @facade.recipe_category_filter_data
    
    assert_kind_of FilterComponent::Data, filter_data
    assert_equal "Recipe Categories", filter_data.title
  end
end
