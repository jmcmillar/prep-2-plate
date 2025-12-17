require "test_helper"

class Admin::Ingredients::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @ingredient = ingredients(:one)
    @facade = Admin::Ingredients::EditFacade.new(@user, { id: @ingredient.id })
  end

  def test_ingredient
    assert_equal @ingredient, @facade.ingredient
  end

  def test_ingredient_persisted
    assert @facade.ingredient.persisted?
  end

  def test_active_key
    assert_equal :admin_ingredients, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Ingredients", trail[1].text
    assert_equal "Edit", trail[2].text
  end

  def test_breadcrumb_trail_paths
    trail = @facade.breadcrumb_trail
    
    assert_equal [:admin, :recipes], trail[0].path
    assert_equal [:admin, :ingredients], trail[1].path
    assert_nil trail[2].path
  end

  def test_form_url
    assert_equal [:admin, @ingredient], @facade.form_url
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
end
