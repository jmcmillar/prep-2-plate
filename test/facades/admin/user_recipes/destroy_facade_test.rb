require "test_helper"

class Admin::UserRecipes::DestroyFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @user = users(:two)
    @recipe = recipes(:one)
    @user_recipe = @user.user_recipes.create!(recipe: @recipe)
    @facade = Admin::UserRecipes::DestroyFacade.new(@admin, { id: @user_recipe.id })
  end

  def test_user_recipe
    assert_equal @user_recipe, @facade.user_recipe
  end
end
