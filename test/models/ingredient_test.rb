require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  def setup
    @ingredient = ingredients(:one)
  end

  def test_valid_ingredient
    ingredient = Ingredient.new(name: "Tomato")
    assert ingredient.valid?
  end

  def test_name_required
    ingredient = Ingredient.new(name: nil)
    assert_not ingredient.valid?
    assert_includes ingredient.errors[:name], "can't be blank"
  end

  def test_name_uniqueness_case_insensitive
    Ingredient.create!(name: "Tomato")
    duplicate = Ingredient.new(name: "TOMATO")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  def test_downcase_fields_before_save
    ingredient = Ingredient.create!(name: "UPPERCASE")
    assert_equal "uppercase", ingredient.reload.name
  end

  def test_ingredient_category_association_optional
    ingredient = Ingredient.new(name: "Test Ingredient")
    assert ingredient.valid?
    assert_nil ingredient.ingredient_category
  end

  def test_ingredient_category_association
    category = ingredient_categories(:one)
    ingredient = Ingredient.create!(name: "Test Ingredient", ingredient_category: category)
    assert_equal category, ingredient.ingredient_category
  end

  def test_ingredient_category_name_delegation
    category = ingredient_categories(:one)
    ingredient = Ingredient.create!(name: "Test Ingredient", ingredient_category: category)
    assert_equal category.name, ingredient.ingredient_category_name
  end

  def test_ingredient_category_name_delegation_when_nil
    ingredient = Ingredient.create!(name: "Test Ingredient")
    assert_nil ingredient.ingredient_category_name
  end

  def test_restrict_deletion_when_used_in_recipes
    ingredient = ingredients(:one)
    recipe = recipes(:one)
    RecipeIngredient.create!(
      recipe: recipe,
      ingredient: ingredient,
      numerator: 1,
      denominator: 1
    )

    assert_no_difference "Ingredient.count" do
      ingredient.destroy
    end
    assert_includes ingredient.errors[:base], "Cannot delete record because dependent recipe ingredients exist"
  end

  def test_filtered_by_ingredient_category_scope
    category = ingredient_categories(:one)
    ingredient1 = Ingredient.create!(name: "ingredient1", ingredient_category: category)
    ingredient2 = Ingredient.create!(name: "ingredient2", ingredient_category: category)
    ingredient3 = Ingredient.create!(name: "ingredient3")

    results = Ingredient.filtered_by_ingredient_category([category.id])
    assert_includes results, ingredient1
    assert_includes results, ingredient2
    assert_not_includes results, ingredient3
  end

  def test_filtered_by_ingredient_category_scope_with_blank_ids
    all_ingredients = Ingredient.all
    results = Ingredient.filtered_by_ingredient_category(nil)
    assert_equal all_ingredients.count, results.count
  end

  def test_ransackable_attributes
    assert_includes Ingredient.ransackable_attributes, "name"
  end

  def test_ransackable_associations
    assert_empty Ingredient.ransackable_associations
  end
end
