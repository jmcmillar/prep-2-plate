require "test_helper"

class Api::Homes::ShowFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @user.recipe_favorites.create!(recipe: @recipe)
    @facade = Api::Homes::ShowFacade.new(@user, {})
  end

  def test_user_id
    assert_equal @user.id, @facade.user_id
  end

  def test_user_name
    assert_equal @user.first_name, @facade.user_name
  end

  def test_recipes
    recipes = @facade.recipes
    
    assert_kind_of ActiveRecord::Relation, recipes
  end

  def test_recommendations
    recommendations = @facade.recommendations
    
    assert_kind_of Array, recommendations
  end
end
