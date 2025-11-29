require "test_helper"

class Recipes::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    @recipe = recipes(:one)
    @facade = Recipes::ResourceFacade.new(@recipe)
  end

  def test_resource_returns_recipe
    assert_equal @recipe, @facade.resource
  end

  def test_image_returns_recipe_image
    assert_equal @recipe.image, @facade.image
  end

  def test_description_returns_recipe_description
    assert_equal @recipe.description, @facade.description
  end

  def test_name_returns_recipe_name
    assert_equal @recipe.name, @facade.name
  end

  def test_meal_types_returns_array_of_names
    assert_instance_of Array, @facade.meal_types
  end

  def test_recipe_categories_returns_array_of_names
    assert_instance_of Array, @facade.recipe_categories
  end

  def test_row_id_returns_formatted_string
    assert_equal "recipe_#{@recipe.id}", @facade.row_id
  end

  def test_id_returns_recipe_id
    assert_equal @recipe.id, @facade.id
  end
end
