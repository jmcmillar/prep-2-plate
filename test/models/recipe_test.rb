require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  context "associations" do
    should have_rich_text(:description)
    should have_one_attached(:image)
    should have_many(:meal_plan_recipes).dependent(:destroy)
    should have_many(:recipe_ingredients).dependent(:destroy)
    should have_many(:ingredients).through(:recipe_ingredients)
    should have_many(:recipe_category_assignments).dependent(:destroy)
    should have_many(:recipe_categories).through(:recipe_category_assignments)
    should have_many(:recipe_meal_types).dependent(:destroy)
    should have_many(:meal_types).through(:recipe_meal_types)
    should have_many(:measurement_units).through(:recipe_ingredients)
    should belong_to(:recipe_import).class_name("RecipeImport").optional(:true)
  end
  
  context "validations" do
    should validate_presence_of(:name)
  end

  def test_filtered_by_recipe_categories
    filtered_recipes = Recipe.filtered_by_recipe_categories([recipe_categories(:one).id])
    assert_includes(filtered_recipes, recipes(:one))
    assert_not_includes(filtered_recipes, recipes(:two))
  end

  def test_filtered_by_recipe_categories_with_blank
    filtered_recipes = Recipe.filtered_by_recipe_categories([])
    assert_equal Recipe.all, filtered_recipes
  end

  def test_filtered_by_meal_types
    filtered_recipes = Recipe.filtered_by_meal_types([meal_types(:one).id])
    assert_includes(filtered_recipes, recipes(:one))
    assert_not_includes(filtered_recipes, recipes(:two))
  end

  def test_filtered_by_meal_types_with_blank
    filtered_recipes = Recipe.filtered_by_meal_types([])
    assert_equal Recipe.all, filtered_recipes
  end

  def test_featured_scope
    recipes(:one).update(featured: true)

    assert_includes Recipe.featured, recipes(:one)
    assert_not_includes Recipe.featured, recipes(:two)
  end
end
