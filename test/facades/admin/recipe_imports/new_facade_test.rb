require "test_helper"

class Admin::RecipeImports::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @url = "https://example.com/recipe"
    @facade = Admin::RecipeImports::NewFacade.new(@admin, {}, strong_params: { url: @url })
  end

  def test_import
    import = @facade.import
    
    assert_kind_of RecipeImport, import
    assert_equal @url, import.url
  end

  def test_active_key
    assert_equal :admin_recipes, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Recipes", trail[1].text
    assert_equal "New Import", trail[2].text
  end

  def test_form_url
    assert_equal [:admin, :recipe_imports], @facade.form_url
  end
end
