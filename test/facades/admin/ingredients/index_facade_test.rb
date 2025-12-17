require "test_helper"

class Admin::Ingredients::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @ingredient = ingredients(:one)
    @facade = Admin::Ingredients::IndexFacade.new(@user, {})
  end

  def test_active_key
    assert_equal :admin_ingredients, @facade.active_key
  end

  def test_base_collection
    assert_includes @facade.base_collection, @ingredient
  end

  def test_base_collection_ordered_by_name
    ingredient_a = Ingredient.create!(name: "apple")
    ingredient_z = Ingredient.create!(name: "zucchini")
    
    facade = Admin::Ingredients::IndexFacade.new(@user, {})
    collection = facade.base_collection.to_a
    
    assert collection.index(ingredient_a) < collection.index(ingredient_z)
  end

  def test_base_collection_filtered_by_category
    category = ingredient_categories(:one)
    ingredient_with_category = Ingredient.create!(name: "categorized", ingredient_category: category)
    ingredient_without_category = Ingredient.create!(name: "uncategorized")
    
    facade = Admin::Ingredients::IndexFacade.new(@user, { ingredient_category_ids: [category.id] })
    collection = facade.base_collection
    
    assert_includes collection, ingredient_with_category
    assert_not_includes collection, ingredient_without_category
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 2, trail.length
    assert_equal "Admin", trail.first.text
    assert_equal "Ingredients", trail.last.text
  end

  def test_breadcrumb_trail_paths
    trail = @facade.breadcrumb_trail
    
    assert_equal [:admin, :recipes], trail.first.path
    assert_nil trail.last.path
  end

  def test_search_data
    search_data = @facade.search_data
    
    assert_kind_of SearchFormComponent::Data, search_data
    assert_equal "Search Name", search_data.label
    assert_equal :name_cont, search_data.field
    assert_equal [:admin, :ingredients], search_data.form_url
  end

  def test_new_action_data
    action = @facade.new_action_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal "New Ingredient", action.label
    assert_equal :plus, action.icon
    assert_equal [:new, :admin, :ingredient], action.path
    assert_equal "_top", action.options[:target]
  end

  def test_ingredient_category_filter_data
    filter_data = @facade.ingredient_category_filter_data
    
    assert_kind_of FilterComponent::Data, filter_data
    assert_equal "Categories", filter_data.title
    assert_equal "ingredient_category_ids[]", filter_data.param_key
    assert_kind_of Array, filter_data.collection
  end

  def test_resource_facade_class
    assert_equal Admin::Ingredients::ResourceFacade, @facade.resource_facade_class
  end
end
