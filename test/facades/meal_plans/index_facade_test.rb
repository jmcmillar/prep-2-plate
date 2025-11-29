require "test_helper"

class MealPlans::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @meal_plan = meal_plans(:one)
    @facade = MealPlans::IndexFacade.new(@user, {})
  end

  def test_base_collection
    assert_includes @facade.base_collection, @meal_plan
  end

  def test_collection
    assert_kind_of CollectionBuilder, @facade.collection
  end

  def test_search_data
    search_data = @facade.search_data
    
    assert_kind_of SearchFormComponent::Data, search_data
    assert_equal [:meal_plans], search_data.form_url
    assert_equal "Search By Name", search_data.label
  end

  def test_resource_facade_class
    assert_equal MealPlans::ResourceFacade, @facade.resource_facade_class
  end

  def test_active_key
    assert_equal :meal_plans, @facade.active_key
  end
end
