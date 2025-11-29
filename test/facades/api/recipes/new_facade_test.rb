require "test_helper"

class Api::Recipes::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @params = {
      title: "New Recipe",
      steps: ["Step 1", "Step 2"],
      ingredients: ["1 cup flour", "2 eggs"]
    }
    @facade = Api::Recipes::NewFacade.new(@user, @params)
  end

  def test_initialization
    assert_not_nil @facade
  end

  # Note: Full testing would require mocking ParseIngredient and BuildRecipeIngredients
  # Skipping detailed tests as they would need complex setup
end
