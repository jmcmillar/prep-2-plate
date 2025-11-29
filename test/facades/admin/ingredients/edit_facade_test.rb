require "test_helper"

class Admin::Ingredients::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @ingredient = ingredients(:one)
    @facade = Admin::Ingredients::EditFacade.new(@user, { id: @ingredient.id })
  end

  def test_ingredient
    assert_equal @ingredient, @facade.ingredient
  end

  def test_active_key
    assert_equal :admin_ingredients, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Ingredients", trail[1].text
    assert_equal "Edit", trail[2].text
  end

  def test_form_url
    assert_equal [:admin, @ingredient], @facade.form_url
  end

  def test_cancel_path
    assert_equal [:admin, :ingredients], @facade.cancel_path
  end
end
