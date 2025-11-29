require "test_helper"

class Admin::RecipeCategories::DestroyFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @category = recipe_categories(:one)
    @facade = Admin::RecipeCategories::DestroyFacade.new(@admin, { id: @category.id })
  end

  def test_recipe_category
    assert_equal @category, @facade.recipe_category
  end
end
