require "test_helper"

class Admin::Recipes::DestroyFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @recipe = Recipe.create!(
      name: "Test Recipe",
      difficulty_level: "easy"
    )
    @facade = Admin::Recipes::DestroyFacade.new(@admin, { id: @recipe.id })
  end

  def test_recipe
    assert_equal @recipe, @facade.recipe
  end
end
