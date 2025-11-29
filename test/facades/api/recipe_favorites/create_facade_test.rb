require "test_helper"

class Api::RecipeFavorites::CreateFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    # Clear any existing favorites
    @user.recipe_favorites.where(recipe: @recipe).destroy_all
  end

  def test_toggle_favorite_when_not_favorited
    facade = Api::RecipeFavorites::CreateFacade.new(@user, { recipe_id: @recipe.id })
    initial_count = @user.recipe_favorites.count
    
    facade.toggle_favorite
    
    assert_equal initial_count + 1, @user.recipe_favorites.count
  end

  def test_toggle_favorite_when_already_favorited
    @user.recipe_favorites.create!(recipe: @recipe)
    facade = Api::RecipeFavorites::CreateFacade.new(@user, { recipe_id: @recipe.id })
    initial_count = @user.recipe_favorites.count
    
    facade.toggle_favorite
    
    assert_equal initial_count - 1, @user.recipe_favorites.count
  end

  def test_message_when_not_favorited
    facade = Api::RecipeFavorites::CreateFacade.new(@user, { recipe_id: @recipe.id })
    
    assert_equal "Recipe added to favorites", facade.message
  end

  def test_message_when_favorited
    @user.recipe_favorites.create!(recipe: @recipe)
    facade = Api::RecipeFavorites::CreateFacade.new(@user, { recipe_id: @recipe.id })
    
    assert_equal "Recipe removed from favorites", facade.message
  end
end
