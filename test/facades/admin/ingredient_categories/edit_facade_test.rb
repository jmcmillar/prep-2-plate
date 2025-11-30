require "test_helper"

class Admin::IngredientCategories::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @ingredient_category = IngredientCategory.create!(name: "Vegetables")
    @facade = Admin::IngredientCategories::EditFacade.new(@user, { id: @ingredient_category.id })
  end

  def test_ingredient_category
    assert_equal @ingredient_category, @facade.ingredient_category
  end

  def test_active_key
    assert_equal :admin_ingredient_categories, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Ingredient Categories", trail[1].text
    assert_equal "Edit", trail[2].text
  end
end
