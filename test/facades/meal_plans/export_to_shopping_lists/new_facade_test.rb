require "test_helper"

class MealPlans::ExportToShoppingLists::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @meal_plan = @user.meal_plans.create!(name: "Test Meal Plan")
    @facade = MealPlans::ExportToShoppingLists::NewFacade.new(@user, { meal_plan_id: @meal_plan.id })
  end

  def test_meal_plan
    assert_equal @meal_plan, @facade.meal_plan
  end

  def test_shopping_lists
    lists = @facade.shopping_lists
    
    assert_kind_of ActiveRecord::Relation, lists
  end

  def test_ingredients
    ingredients = @facade.ingredients
    
    assert_kind_of ActiveRecord::Relation, ingredients
  end

  def test_active_key
    assert_equal :meal_plans, @facade.active_key
  end

  def test_form_url
    assert_equal [@meal_plan, :export_to_shopping_list], @facade.form_url
  end

  def test_shopping_list_new_when_no_id
    list = @facade.shopping_list

    # Returns nil when no strong_params provided
    assert_nil list
  end

  def test_ingredients_include_packaging_and_preparation
    # Add a recipe with ingredients to the meal plan
    recipe = recipes(:one)
    @meal_plan.meal_plan_recipes.create!(recipe: recipe)

    ingredients = @facade.ingredients

    # Should return MealPlanIngredient records
    assert ingredients.any?, "Should have ingredients"

    ingredient = ingredients.first
    assert_respond_to ingredient, :packaging_form, "Should respond to packaging_form"
    assert_respond_to ingredient, :preparation_style, "Should respond to preparation_style"
    assert_respond_to ingredient, :ingredient_id, "Should respond to ingredient_id"
  end

  def test_creates_shopping_list_items_with_ingredient_metadata
    # Setup: Create a shopping list and add an ingredient to the meal plan
    shopping_list = @user.shopping_lists.create!(name: "My List")
    recipe = recipes(:one)
    @meal_plan.meal_plan_recipes.create!(recipe: recipe)

    ingredient = @facade.ingredients.first

    # Strong params simulating form submission
    strong_params = {
      shopping_list_id: shopping_list.id,
      shopping_list_items_attributes: {
        "0" => {
          name: ingredient.name,
          ingredient_id: ingredient.ingredient_id,
          packaging_form: ingredient.packaging_form,
          preparation_style: ingredient.preparation_style
        }
      }
    }

    facade_with_params = MealPlans::ExportToShoppingLists::NewFacade.new(
      @user,
      { meal_plan_id: @meal_plan.id },
      strong_params: strong_params
    )

    list = facade_with_params.shopping_list

    assert_not_nil list, "Should create shopping list"
    assert_equal 1, list.shopping_list_items.size, "Should have 1 item"

    item = list.shopping_list_items.first
    assert_equal ingredient.ingredient_id, item.ingredient_id, "Should preserve ingredient_id"
    assert_equal ingredient.packaging_form, item.packaging_form, "Should preserve packaging_form"
    assert_equal ingredient.preparation_style, item.preparation_style, "Should preserve preparation_style"
    assert_equal ingredient.name, item.name, "Should preserve name"
  end

  def test_handles_missing_packaging_and_preparation
    # Setup: Create ingredient without packaging/preparation
    shopping_list = @user.shopping_lists.create!(name: "My List")

    strong_params = {
      shopping_list_id: shopping_list.id,
      shopping_list_items_attributes: {
        "0" => {
          name: "Custom item",
          ingredient_id: nil,
          packaging_form: nil,
          preparation_style: nil
        }
      }
    }

    facade_with_params = MealPlans::ExportToShoppingLists::NewFacade.new(
      @user,
      { meal_plan_id: @meal_plan.id },
      strong_params: strong_params
    )

    list = facade_with_params.shopping_list

    assert_not_nil list, "Should create shopping list"
    assert_equal 1, list.shopping_list_items.size, "Should have 1 item"

    item = list.shopping_list_items.first
    assert_nil item.ingredient_id, "Should allow nil ingredient_id"
    assert_nil item.packaging_form, "Should allow nil packaging_form"
    assert_nil item.preparation_style, "Should allow nil preparation_style"
    assert_equal "Custom item", item.name, "Should preserve name"
  end

  def test_creates_new_shopping_list_when_no_id_provided
    strong_params = {
      shopping_list_items_attributes: {
        "0" => {
          name: "Test item",
          ingredient_id: nil,
          packaging_form: nil,
          preparation_style: nil
        }
      }
    }

    facade_with_params = MealPlans::ExportToShoppingLists::NewFacade.new(
      @user,
      { meal_plan_id: @meal_plan.id },
      strong_params: strong_params
    )

    list = facade_with_params.shopping_list

    assert_not_nil list, "Should create new shopping list"
    assert_equal "Main Shopping List", list.name, "Should use default name"
    assert list.new_record?, "Should be a new record (not saved yet)"
    assert_equal 1, list.shopping_list_items.size, "Should have 1 item"
  end
end
