require "test_helper"

class RecipeFavorites::DestroyFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @recipe_favorite = @user.recipe_favorites.create!(recipe: @recipe)
    @facade = RecipeFavorites::DestroyFacade.new(@user, { id: @recipe_favorite.id })
  end

  def test_recipe_favorite
    assert_equal @recipe_favorite.id, @facade.recipe_favorite.id
  end

  def test_recipe
    assert_equal @recipe, @facade.recipe
  end
end
