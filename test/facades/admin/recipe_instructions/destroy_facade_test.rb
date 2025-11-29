require "test_helper"

class Admin::RecipeInstructions::DestroyFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @recipe = recipes(:one)
    @instruction = @recipe.recipe_instructions.create!(
      instruction: "Test instruction",
      step_number: 1
    )
    @facade = Admin::RecipeInstructions::DestroyFacade.new(@admin, { id: @instruction.id })
  end

  def test_recipe_instruction
    assert_equal @instruction, @facade.recipe_instruction
  end
end
