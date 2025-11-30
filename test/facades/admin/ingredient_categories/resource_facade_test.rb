require "test_helper"

class Admin::IngredientCategories::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    @ingredient_category = IngredientCategory.create!(name: "Vegetables")
    @facade = Admin::IngredientCategories::ResourceFacade.new(@ingredient_category)
  end

  def test_headers
    headers = Admin::IngredientCategories::ResourceFacade.headers
    
    assert_equal 1, headers.length
    assert_kind_of Table::DefaultHeaderComponent, headers.first
  end

  def test_to_row
    row = Admin::IngredientCategories::ResourceFacade.to_row(@facade)
    
    assert_kind_of Table::RowComponent, row
    assert_equal "ingredient_category_#{@ingredient_category.id}", row.id
  end

  def test_name
    name_component = @facade.name
    
    assert_kind_of Table::DataComponent, name_component
  end

  def test_id
    assert_equal "ingredient_category_#{@ingredient_category.id}", @facade.id
  end

  def test_action
    action = @facade.action
    
    assert_kind_of Table::ActionComponent, action
  end

  def test_action_turbo_data
    turbo_data = @facade.action_turbo_data
    
    assert_kind_of TurboData, turbo_data
    assert_equal :table_actions, turbo_data.target
  end
end
