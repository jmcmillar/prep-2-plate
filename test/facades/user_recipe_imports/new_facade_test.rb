require "test_helper"

class UserRecipeImports::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @url = "https://example.com/recipe"
  end
end
