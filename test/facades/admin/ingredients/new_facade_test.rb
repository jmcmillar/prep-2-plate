require "test_helper"

class Admin::Ingredients::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @facade = Admin::Ingredients::NewFacade.new(@user, {})
  end

  def test_ingredient
    assert_kind_of Ingredient, @facade.ingredient
  end

  def test_ingredient_new_record
    assert @facade.ingredient.new_record?
  end

  def test_ingredient_not_persisted
    assert_not @facade.ingredient.persisted?
  end

  def test_active_key
    assert_equal :admin_ingredients, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Ingredients", trail[1].text
    assert_equal "New", trail[2].text
  end

  def test_breadcrumb_trail_paths
    trail = @facade.breadcrumb_trail
    
    assert_equal [:admin, :recipes], trail[0].path
    assert_equal [:admin, :ingredients], trail[1].path
    assert_nil trail[2].path
  end

  def test_form_url
    expected_url = [:admin, @facade.ingredient]
    assert_equal expected_url, @facade.form_url
  end

  def test_cancel_path
    assert_equal [:admin, :ingredients], @facade.cancel_path
  end

  def test_ingredient_categories
    categories = @facade.ingredient_categories
    
    assert_kind_of ActiveRecord::Relation, categories
    assert_equal IngredientCategory.order(:name).to_a, categories.to_a
  end

  def test_ingredient_categories_ordered_by_name
    category_a = IngredientCategory.create!(name: "A Category")
    category_z = IngredientCategory.create!(name: "Z Category")
    
    categories = @facade.ingredient_categories.to_a
    
    assert categories.index(category_a) < categories.index(category_z)
  end

  def test_multiple_facades_have_different_ingredient_instances
    facade1 = Admin::Ingredients::NewFacade.new(@user, {})
    facade2 = Admin::Ingredients::NewFacade.new(@user, {})
    
    assert_not_equal facade1.ingredient.object_id, facade2.ingredient.object_id
  end
end
