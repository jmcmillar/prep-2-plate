require "test_helper"

class Admin::IngredientCategories::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @facade = Admin::IngredientCategories::NewFacade.new(@user, {})
  end

  def test_ingredient_category_is_not_persisted
    assert @facade.ingredient_category.new_record?
  end

  def test_active_key
    assert_equal :admin_ingredient_categories, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Ingredient Categories", trail[1].text
    assert_equal "New", trail[2].text
  end
end
