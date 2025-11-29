require "test_helper"

class MyRecipes::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @user_recipe = user_recipes(:one)
    @facade = MyRecipes::IndexFacade.new(@user, {})
  end

  def test_base_collection
    assert_includes @facade.base_collection, @user_recipe.recipe
  end

  def test_collection
    assert_kind_of CollectionBuilder, @facade.collection
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 2, trail.length
    assert_equal "Recipes", trail.first.text
    assert_equal "My Recipes", trail.last.text
  end

  def test_favorites
    assert_kind_of CollectionBuilder, @facade.favorites
  end

  def test_favorite_collection
    favorite = @user.recipe_favorites.create!(recipe: recipes(:two))
    
    assert_includes @facade.favorite_collection, recipes(:two)
  end

  def test_search_data
    search_data = @facade.search_data
    
    assert_kind_of SearchFormComponent::Data, search_data
    assert_equal [:my_recipes], search_data.form_url
  end

  def test_meal_type_filter_data
    filter_data = @facade.meal_type_filter_data
    
    assert_kind_of FilterComponent::Data, filter_data
    assert_equal "Meal Types", filter_data.title
  end
end
