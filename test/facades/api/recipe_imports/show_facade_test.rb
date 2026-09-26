require "test_helper"

class Api::RecipeImports::ShowFacadeTest < ActiveSupport::TestCase
  PageResponse = Struct.new(:body, :headers)

  def setup
    @user = users(:one)
    @facade = Api::RecipeImports::ShowFacade.new(@user, { url: "https://example.com/recipe" })
  end

  def test_recipe
    with_page do
      assert_kind_of Hash, @facade.recipe
      assert_equal "Grandma's Lemon Bars", @facade.recipe[:name]
    end
  end

  def test_duration_falls_back_to_prep_plus_cook
    with_page { assert_equal 55, @facade.duration }
  end

  private

  def with_page(&block)
    page = PageResponse.new(file_fixture("recipe_pages/wprm_graph.html").read, {})
    Import::SafeFetch.stub(:get, page, &block)
  end
end
