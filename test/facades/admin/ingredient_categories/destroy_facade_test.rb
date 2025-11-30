require "test_helper"

class Admin::IngredientCategories::DestroyFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @ingredient_category = IngredientCategory.create!(name: "Vegetables")
    @facade = Admin::IngredientCategories::DestroyFacade.new(@user, { id: @ingredient_category.id })
  end

  def test_ingredient_category
    assert_equal @ingredient_category, @facade.ingredient_category
  end

  def test_ingredient_category_can_be_destroyed
    assert @facade.ingredient_category.destroy
    assert @facade.ingredient_category.destroyed?
  end
end
