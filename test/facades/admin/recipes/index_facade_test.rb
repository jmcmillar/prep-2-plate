require "test_helper"

class Admin::Recipes::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    # Create a recipe without user_recipe association (admin recipes only show recipes without user_recipe)
    @recipe = Recipe.create!(name: "Admin Recipe", recipe_import_id: nil)
    @facade = Admin::Recipes::IndexFacade.new(@user, {})
  end

  def test_active_key
    assert_equal :admin_recipes, @facade.active_key
  end

  def test_base_collection
    assert_includes @facade.base_collection, @recipe
  end

  def test_base_collection_excludes_user_recipes
    user_recipe = Recipe.create!(name: "User Recipe")
    UserRecipe.create!(user: @user, recipe: user_recipe)
    
    facade = Admin::Recipes::IndexFacade.new(@user, {})
    
    assert_includes facade.base_collection, @recipe
    assert_not_includes facade.base_collection, user_recipe
  end

  def test_base_collection_ordered_by_name
    recipe_a = Recipe.create!(name: "Apple Pie")
    recipe_z = Recipe.create!(name: "Zucchini Bread")
    
    facade = Admin::Recipes::IndexFacade.new(@user, {})
    collection = facade.base_collection.to_a
    
    assert collection.index(recipe_a) < collection.index(recipe_z)
  end

  def test_base_collection_filtered_by_meal_types
    meal_type = MealType.create!(name: "Test Breakfast #{Time.now.to_i}")
    recipe_with_meal_type = Recipe.create!(name: "Test Breakfast Recipe #{Time.now.to_i}")
    recipe_with_meal_type.meal_types << meal_type
    recipe_without_meal_type = Recipe.create!(name: "Test Other Recipe #{Time.now.to_i}")

    facade = Admin::Recipes::IndexFacade.new(@user, { meal_type_ids: [meal_type.id] })
    collection = facade.base_collection

    assert_includes collection, recipe_with_meal_type
    assert_not_includes collection, recipe_without_meal_type
  end

  def test_base_collection_filtered_by_recipe_categories
    category = RecipeCategory.create!(name: "Test Dessert #{Time.now.to_i}")
    recipe_with_category = Recipe.create!(name: "Test Dessert Recipe #{Time.now.to_i}")
    recipe_with_category.recipe_categories << category
    recipe_without_category = Recipe.create!(name: "Test Another Recipe #{Time.now.to_i}")
    
    facade = Admin::Recipes::IndexFacade.new(@user, { recipe_category_ids: [category.id] })
    collection = facade.base_collection
    
    assert_includes collection, recipe_with_category
    assert_not_includes collection, recipe_without_category
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 2, trail.length
    assert_equal "Admin", trail.first.text
    assert_equal "Recipes", trail.last.text
  end

  def test_breadcrumb_trail_paths
    trail = @facade.breadcrumb_trail
    
    assert_equal [:admin, :recipes], trail.first.path
    assert_nil trail.last.path
  end

  def test_search_data
    search_data = @facade.search_data
    
    assert_kind_of SearchFormComponent::Data, search_data
    assert_equal "Search Name, Meal Types, Categories", search_data.label
    assert_equal :name_cont, search_data.field
    assert_equal [:admin, :recipes], search_data.form_url
  end

  def test_header_actions
    actions = @facade.header_actions
    
    assert_equal 2, actions.length
    assert_kind_of IconLinkComponent::Data, actions[0]
    assert_kind_of IconLinkComponent::Data, actions[1]
  end

  def test_import_action_data
    action = @facade.import_action_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal "Import New Recipe", action.label
    assert_equal :file_import, action.icon
    assert_equal [:new, :admin, :recipe_import], action.path
  end

  def test_new_action_data
    action = @facade.new_action_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal "New Recipe", action.label
    assert_equal :plus, action.icon
    assert_equal [:new, :admin, :recipe], action.path
  end

  def test_meal_type_filter_data
    filter_data = @facade.meal_type_filter_data
    
    assert_kind_of FilterComponent::Data, filter_data
    assert_equal "Meal Types", filter_data.title
    assert_equal "meal_type_ids[]", filter_data.param_key
    assert_kind_of Array, filter_data.collection
  end

  def test_recipe_category_filter_data
    filter_data = @facade.recipe_category_filter_data
    
    assert_kind_of FilterComponent::Data, filter_data
    assert_equal "Recipe Categories", filter_data.title
    assert_equal "recipe_category_ids[]", filter_data.param_key
    assert_kind_of Array, filter_data.collection
  end

  def test_resource_facade_class
    assert_equal Admin::Recipes::ResourceFacade, @facade.resource_facade_class
  end
end
