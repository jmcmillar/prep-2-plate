require "test_helper"

class RecipeFavorites::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @facade = RecipeFavorites::NewFacade.new(@user, { recipe_id: @recipe.id })
  end

  def test_recipe
    assert_equal @recipe, @facade.recipe
  end

  def test_favorite_is_not_persisted
    assert @facade.recipe_favorite.new_record?
  end
end
