require "test_helper"

class Admin::UserRecipes::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @user = users(:two)
    @recipe = recipes(:one)
    @user_recipe = @user.user_recipes.create!(recipe: @recipe)
    @facade = Admin::UserRecipes::EditFacade.new(@admin, { id: @user_recipe.id })
  end

  def test_user_recipe
    assert_equal @user_recipe, @facade.user_recipe
  end

  def test_parent_resource
    assert_equal @user, @facade.parent_resource
  end

  def test_menu
    assert_equal :admin_user_menu, @facade.menu
  end

  def test_active_key
    assert_equal :admin_user_recipes, @facade.active_key
  end

  def test_nav_resource
    assert_equal @user, @facade.nav_resource
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 6, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Users", trail[1].text
    assert_equal "Recipes", trail[3].text
    assert_equal "Edit", trail[5].text
  end

  def test_form_url
    assert_equal [:admin, @user_recipe], @facade.form_url
  end

  def test_difficulty_levels
    levels = @facade.difficulty_levels
    
    assert_kind_of Array, levels
    assert levels.length > 0
  end
end
