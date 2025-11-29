require "test_helper"

class Api::RecipeImports::ShowFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @url = "https://example.com/recipe"
    @facade = Api::RecipeImports::ShowFacade.new(@user, { url: @url })
  end

  def test_recipe
    recipe = @facade.recipe
    
    assert_kind_of Hash, recipe
  end
end
