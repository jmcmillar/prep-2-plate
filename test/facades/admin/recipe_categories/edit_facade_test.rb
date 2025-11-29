require "test_helper"

class Admin::RecipeCategories::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe_category = recipe_categories(:one)
    @facade = Admin::RecipeCategories::EditFacade.new(@user, { id: @recipe_category.id })
  end

  def test_recipe_category
    assert_equal @recipe_category, @facade.recipe_category
  end

  def test_active_key
    assert_equal :admin_recipe_categories, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Recipe Categories", trail[1].text
    assert_equal "Edit", trail[2].text
  end
end
