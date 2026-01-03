require "test_helper"

class Ingredient::DisplayNameDecoratorTest < ActiveSupport::TestCase
  def test_display_name_with_name_only
    ingredient = Ingredient.new(name: "tomatoes")
    decorated = Ingredient::DisplayNameDecorator.decorate(ingredient)
    assert_equal "tomatoes", decorated.display_name
  end

  def test_display_name_with_packaging_form_only
    ingredient = Ingredient.new(name: "tomatoes", packaging_form: "canned")
    decorated = Ingredient::DisplayNameDecorator.decorate(ingredient)
    assert_equal "canned tomatoes", decorated.display_name
  end

  def test_display_name_with_preparation_style_only
    ingredient = Ingredient.new(name: "tomatoes", preparation_style: "diced")
    decorated = Ingredient::DisplayNameDecorator.decorate(ingredient)
    assert_equal "diced tomatoes", decorated.display_name
  end

  def test_display_name_with_packaging_and_preparation
    ingredient = Ingredient.new(
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced"
    )
    decorated = Ingredient::DisplayNameDecorator.decorate(ingredient)
    assert_equal "canned diced tomatoes", decorated.display_name
  end

  def test_display_name_is_downcased
    ingredient = Ingredient.new(
      name: "Tomatoes",
      packaging_form: "frozen",
      preparation_style: "chopped"
    )
    decorated = Ingredient::DisplayNameDecorator.decorate(ingredient)
    assert_equal "frozen chopped tomatoes", decorated.display_name
    refute_match(/[A-Z]/, decorated.display_name, "Display name should not contain uppercase letters")
  end

  def test_display_name_with_all_packaging_forms
    Ingredient::PACKAGING_FORMS.each do |key, value|
      ingredient = Ingredient.new(name: "beans", packaging_form: key.to_s)
      decorated = Ingredient::DisplayNameDecorator.decorate(ingredient)
      expected = "#{value.downcase} beans"
      assert_equal expected, decorated.display_name, "Failed for packaging form: #{key}"
    end
  end

  def test_display_name_with_all_preparation_styles
    Ingredient::PREPARATION_STYLES.each do |key, value|
      ingredient = Ingredient.new(name: "carrots", preparation_style: key.to_s)
      decorated = Ingredient::DisplayNameDecorator.decorate(ingredient)
      expected = "#{value.downcase} carrots"
      assert_equal expected, decorated.display_name, "Failed for preparation style: #{key}"
    end
  end

  def test_decorate_collection
    ingredients = [
      Ingredient.new(name: "tomatoes"),
      Ingredient.new(name: "beans", packaging_form: "canned"),
      Ingredient.new(name: "carrots", preparation_style: "diced")
    ]

    decorated_collection = Ingredient::DisplayNameDecorator.decorate_collection(ingredients)

    assert_equal 3, decorated_collection.size
    assert_equal "tomatoes", decorated_collection[0].display_name
    assert_equal "canned beans", decorated_collection[1].display_name
    assert_equal "diced carrots", decorated_collection[2].display_name
  end

  def test_delegates_to_underlying_ingredient
    ingredient = Ingredient.new(name: "tomatoes", packaging_form: "canned")
    decorated = Ingredient::DisplayNameDecorator.decorate(ingredient)

    # Should delegate methods to the underlying ingredient
    assert_equal "tomatoes", decorated.name
    assert_equal "canned", decorated.packaging_form
  end

  def test_original_object_returns_unwrapped_ingredient
    ingredient = Ingredient.new(name: "tomatoes")
    decorated = Ingredient::DisplayNameDecorator.decorate(ingredient)

    assert_equal ingredient, decorated.original_object
  end
end
