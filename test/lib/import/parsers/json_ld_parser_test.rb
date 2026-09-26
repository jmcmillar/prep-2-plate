require "test_helper"

class Import::Parsers::JsonLdParserTest < ActiveSupport::TestCase
  def test_parses_recipe_inside_graph_with_entities_and_sections
    recipe = parse("wprm_graph.html")

    assert_equal "Grandma's Lemon Bars", recipe.name
    assert_equal "Sweet & tangy bars.", recipe.description
    assert_equal "Jane Baker", recipe.author
    assert_equal [ "1 ½ cups all-purpose flour", "1 1⁄2 cups sugar", "3 large eggs" ], recipe.ingredients
    assert_equal [ "Heat oven to 350°F.", "Press dough into the pan.", "Whisk eggs and sugar." ], recipe.instructions
  end

  def test_extracts_image_url_from_image_object_array
    assert_equal "https://example.com/lemon-bars.jpg", parse("wprm_graph.html").image_url
  end

  def test_parses_prep_and_cook_time_when_total_is_missing
    recipe = parse("wprm_graph.html")

    assert_nil recipe.total_time
    assert_equal 15, recipe.prep_time
    assert_equal 40, recipe.cook_time
    assert_equal "16", recipe.yield
  end

  def test_skips_invalid_json_and_accepts_hash_context
    recipe = parse("hash_context_after_bad_json.html")

    assert_equal "Simple Soup", recipe.name
    assert_equal "Chef Sam", recipe.author
    assert_equal "https://example.com/soup.jpg", recipe.image_url
    assert_equal 65, recipe.total_time
    assert_equal 4, recipe.yield
  end

  def test_splits_single_string_instructions_into_steps
    assert_equal [ "Chop the onion.", "Simmer everything for an hour." ], parse("hash_context_after_bad_json.html").instructions
  end

  def test_page_without_recipe_uses_null_parser
    parser = RecipeParser.parser_for("<html><head><title>No recipe</title></head></html>")

    assert_instance_of Import::Parsers::NullRecipeParser, parser
  end

  private

  def parse(fixture)
    RecipeParser.parse(file_fixture("recipe_pages/#{fixture}").read)
  end
end
