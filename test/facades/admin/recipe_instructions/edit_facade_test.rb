require "test_helper"

class Admin::RecipeInstructions::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @recipe = recipes(:one)
    @recipe_instruction = @recipe.recipe_instructions.create!(
      instruction: "Test instruction",
      step_number: 1
    )
    @facade = Admin::RecipeInstructions::EditFacade.new(@admin, { id: @recipe_instruction.id })
  end

  def test_recipe_instruction
    assert_equal @recipe_instruction, @facade.recipe_instruction
  end

  def test_recipe
    assert_equal @recipe, @facade.recipe
  end

  def test_active_key
    assert_equal :admin_recipes, @facade.active_key
  end

  def test_measurement_units
    units = @facade.measurement_units
    
    assert_kind_of ActiveRecord::Relation, units
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Recipe Instructions", trail[1].text
    assert_equal "Edit", trail[2].text
  end

  def test_form_url
    assert_equal [:admin, @recipe_instruction], @facade.form_url
  end

  def test_cancel_path
    assert_equal [:admin, @recipe, :recipe_instructions], @facade.cancel_path
  end
end
