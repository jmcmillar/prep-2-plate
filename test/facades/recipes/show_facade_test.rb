require "test_helper"

class Recipes::ShowFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @facade = Recipes::ShowFacade.new(@user, { id: @recipe.id })
  end

  def test_resource
    assert_equal @recipe, @facade.resource
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 2, trail.length
    assert_equal "Recipes", trail.first.text
    assert_equal @recipe.name, trail.last.text
  end

  def test_level_with_difficulty
    @recipe.update!(difficulty_level: "easy")
    
    assert_equal "Easy", @facade.level
  end

  def test_level_without_difficulty
    @recipe.update!(difficulty_level: nil)
    
    assert_equal "Not specified", @facade.level
  end

  def test_recipe_favorite_toggle_data_when_user_present
    toggle_data = @facade.recipe_favorite_toggle_data
    
    assert_kind_of ToggleFormComponent::Data, toggle_data
  end
end
