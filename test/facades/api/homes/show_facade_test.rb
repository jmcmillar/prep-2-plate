require "test_helper"

class Api::Homes::ShowFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @user.recipe_favorites.find_or_create_by!(recipe: @recipe)
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

  def test_recommendations_exclude_categories_with_only_other_users_recipes
    owner_ids = Api::Homes::ShowFacade.new(users(:one), {}).recommendations.map { |r| r[:id] }
    other_ids = Api::Homes::ShowFacade.new(users(:two), {}).recommendations.map { |r| r[:id] }

    assert_includes owner_ids, recipe_categories(:one).id
    assert_not_includes other_ids, recipe_categories(:one).id
  end
end
