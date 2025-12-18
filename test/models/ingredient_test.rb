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

  # New tests for packaging_form and preparation_style

  def test_allows_nil_packaging_form_and_preparation_style
    ingredient = Ingredient.create(name: "tomatoes")
    assert_nil ingredient.packaging_form
    assert_nil ingredient.preparation_style
    assert_equal "tomatoes", ingredient.display_name
  end

  def test_validates_packaging_form_from_allowed_list
    ingredient = Ingredient.new(name: "tomatoes", packaging_form: "invalid")
    assert_not ingredient.valid?
    assert_includes ingredient.errors[:packaging_form], "is not included in the list"
  end

  def test_validates_preparation_style_from_allowed_list
    ingredient = Ingredient.new(name: "tomatoes", preparation_style: "invalid")
    assert_not ingredient.valid?
    assert_includes ingredient.errors[:preparation_style], "is not included in the list"
  end

  def test_display_name_includes_only_packaging_when_prep_is_nil
    ingredient = Ingredient.create(name: "tomatoes", packaging_form: "canned")
    assert_equal "Canned tomatoes", ingredient.display_name
  end

  def test_display_name_includes_only_preparation_when_packaging_is_nil
    ingredient = Ingredient.create(name: "tomatoes", preparation_style: "diced")
    assert_equal "Diced tomatoes", ingredient.display_name
  end

  def test_display_name_includes_both_packaging_and_preparation
    ingredient = Ingredient.create(
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced"
    )
    assert_equal "Canned Diced tomatoes", ingredient.display_name
  end

  def test_all_forms_of_returns_all_packaging_and_preparation_variants
    # Note: Until MR #5, we still have the old uniqueness constraint on name only
    # So we can only create one "tomatoes" ingredient for now
    # This test will be updated in MR #5 to test multiple variants
    ingredient = Ingredient.create(name: "tomatoes", packaging_form: "canned", preparation_style: "diced")

    tomato_forms = Ingredient.all_forms_of("tomatoes")
    assert_equal 1, tomato_forms.count
    assert_includes tomato_forms, ingredient
  end

  def test_with_packaging_scope_filters_by_packaging_form
    Ingredient.create(name: "tomatoes", packaging_form: "canned")
    Ingredient.create(name: "spinach", packaging_form: "frozen")
    Ingredient.create(name: "apples", packaging_form: "fresh")

    canned = Ingredient.with_packaging(:canned)
    assert_equal 1, canned.count
    assert_equal "tomatoes", canned.first.name
  end

  def test_with_preparation_scope_filters_by_preparation_style
    Ingredient.create(name: "tomatoes", preparation_style: "diced")
    Ingredient.create(name: "carrots", preparation_style: "sliced")
    Ingredient.create(name: "cheese", preparation_style: "shredded")

    diced = Ingredient.with_preparation(:diced)
    assert_equal 1, diced.count
    assert_equal "tomatoes", diced.first.name
  end

  def test_ransackable_attributes_includes_new_fields
    assert_includes Ingredient.ransackable_attributes, "packaging_form"
    assert_includes Ingredient.ransackable_attributes, "preparation_style"
  end
end
