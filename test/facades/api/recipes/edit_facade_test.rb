require "test_helper"

class Api::Recipes::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @user.user_recipes.create!(recipe: @recipe)
    @strong_params = {
      title: "Updated Recipe",
      ingredients: ["1 cup flour", "2 eggs"],
      steps: ["Mix ingredients", "Bake at 350°F"]
    }
    @facade = Api::Recipes::EditFacade.new(@user, { id: @recipe.id }, strong_params: @strong_params)
  end

  def test_recipe_is_found
    assert_equal @recipe, @facade.recipe
  end

  def test_recipe_belongs_to_user
    recipe = @facade.recipe
    assert_equal @user, recipe.user_recipe.user
  end

  def test_updates_instructions
    recipe = @facade.recipe
    recipe.save
    
    assert_equal 2, recipe.recipe_instructions.count
    assert_equal "Mix ingredients", recipe.recipe_instructions.first.instruction
    assert_equal "Bake at 350°F", recipe.recipe_instructions.last.instruction
  end

  def test_handles_blank_steps
    facade = Api::Recipes::EditFacade.new(@user, { id: @recipe.id }, strong_params: { steps: [] })
    recipe = facade.recipe
    
    # Should not raise error
    assert_nothing_raised { recipe }
  end

  def test_handles_blank_ingredients
    facade = Api::Recipes::EditFacade.new(@user, { id: @recipe.id }, strong_params: { ingredients: [] })
    recipe = facade.recipe
    
    # Should not raise error
    assert_nothing_raised { recipe }
  end
end
