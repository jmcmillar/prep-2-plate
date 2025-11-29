require "test_helper"

class Admin::RecipeCategories::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @facade = Admin::RecipeCategories::NewFacade.new(@user, {})
  end

  def test_recipe_category_is_new_record
    assert @facade.recipe_category.new_record?
  end

  def test_active_key
    assert_equal :admin_recipe_categories, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Recipe Categories", trail[1].text
    assert_equal "New", trail[2].text
  end
end
