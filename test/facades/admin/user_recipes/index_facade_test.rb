require "test_helper"

class Admin::UserRecipes::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @user = users(:two)
    @user_recipe = @user.user_recipes.create!(recipe: recipes(:one))
    @facade = Admin::UserRecipes::IndexFacade.new(@admin, { user_id: @user.id })
  end

  def test_menu
    assert_equal :admin_user_menu, @facade.menu
  end

  def test_active_key
    assert_equal :admin_user_recipes, @facade.active_key
  end

  def test_parent_resource
    assert_equal @user, @facade.parent_resource
  end

  def test_nav_resource
    assert_equal @user, @facade.nav_resource
  end

  def test_base_collection
    assert_includes @facade.base_collection, @user_recipe
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 4, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Users", trail[1].text
    assert_equal "Recipes", trail[3].text
  end
end
