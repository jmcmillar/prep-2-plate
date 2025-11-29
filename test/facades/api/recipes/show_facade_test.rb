require "test_helper"

class Api::Recipes::ShowFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @facade = Api::Recipes::ShowFacade.new(@user, { id: @recipe.id })
  end

  def test_id
    assert_equal @recipe.id, @facade.id
  end

  def test_name
    assert_equal @recipe.name, @facade.name
  end

  def test_duration
    assert_equal @recipe.duration_minutes, @facade.duration
  end

  def test_servings
    assert_equal @recipe.serving_size, @facade.servings
  end

  def test_difficulty_level_with_value
    @recipe.update!(difficulty_level: "easy")
    
    assert_equal "Easy", @facade.difficulty_level
  end

  def test_difficulty_level_without_value
    @recipe.update!(difficulty_level: nil)
    
    assert_equal "Unknown", @facade.difficulty_level
  end

  def test_favorite_when_favorited
    @user.recipe_favorites.create!(recipe: @recipe)
    
    assert @facade.favorite?
  end

  def test_favorite_when_not_favorited
    # Remove any existing favorites
    @user.recipe_favorites.where(recipe: @recipe).destroy_all
    
    assert_not @facade.favorite?
  end
end
