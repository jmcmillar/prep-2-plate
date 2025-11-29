require "test_helper"

class Admin::Ingredients::DestroyFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @ingredient = ingredients(:one)
    @facade = Admin::Ingredients::DestroyFacade.new(@admin, { id: @ingredient.id })
  end

  def test_ingredient
    assert_equal @ingredient, @facade.ingredient
  end
end
