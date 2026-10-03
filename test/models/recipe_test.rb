require "test_helper"

class RecipeTest < ActiveSupport::TestCase
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

  def test_visible_to_includes_catalog_and_own_recipes
    visible = Recipe.visible_to(users(:one))

    assert_includes visible, recipes(:one)
    assert_includes visible, recipes(:two)
  end

  def test_visible_to_excludes_other_users_recipes
    visible = Recipe.visible_to(users(:two))

    assert_not_includes visible, recipes(:one)
    assert_includes visible, recipes(:two)
  end

  def test_visible_to_without_user_excludes_all_user_recipes
    assert_not_includes Recipe.visible_to(nil), recipes(:one)
    assert_includes Recipe.visible_to(nil), recipes(:two)
  end
end
