require "test_helper"

class RecipeImports::AiParseIngredientsTest < ActiveSupport::TestCase
  include MeasurementUnitHelper

  class FakeClient
    attr_reader :calls

    def initialize(result)
      @result = result
      @calls = []
    end

    def call(prompt, **options)
      @calls << [ prompt, options ]
      @result
    end
  end

  LINE = "Juice of 1 lemon".freeze

  def setup
    @units = create_parser_units
    @lookup = RecipeUtils::UnitLookup.new
    @cache = ActiveSupport::Cache::MemoryStore.new
  end

  def test_returns_validated_results_keyed_by_line
    client = client_returning([ item(0, quantity: "1", unit: "", name: "Lemons", notes: "juiced") ])

    result = parse([ LINE ], client)

    assert_equal "lemon", result[LINE][:ingredient_name]
    assert_equal "1", result[LINE][:quantity]
    assert_nil result[LINE][:measurement_unit_id]
    assert_equal "juiced", result[LINE][:ingredient_notes]
  end

  def test_sends_haiku_model_and_schema
    client = client_returning([])

    parse([ LINE ], client)

    options = client.calls.first.last
    assert_equal "claude-haiku-4-5", options[:model]
    assert_equal "object", options[:output_schema][:type]
    assert_includes client.calls.first.first, "0: #{LINE}"
  end

  def test_maps_unit_names_to_ids
    client = client_returning([ item(0, quantity: "2", unit: "tablespoon", name: "butter") ])

    assert_equal @units["tablespoon"].id, parse([ LINE ], client)[LINE][:measurement_unit_id]
  end

  def test_drops_items_with_unknown_units_or_invalid_values
    lines = [ "line a", "line b", "line c" ]
    client = client_returning([
      item(0, unit: "smidgen", name: "salt"),
      item(1, packaging_form: "vacuum-sealed", name: "ham"),
      item(2, quantity: "about two", name: "egg")
    ])

    assert_empty parse(lines, client)
  end

  def test_client_failure_returns_empty_hash
    client = FakeClient.new(Base::Result.new(data: nil, success: false, error_message: "boom"))

    assert_equal({}, parse([ LINE ], client))
  end

  def test_malformed_json_returns_empty_hash
    client = FakeClient.new(Base::Result.new(data: "not json", success: true, error_message: nil))

    assert_equal({}, parse([ LINE ], client))
  end

  def test_cached_lines_skip_the_client
    parse([ LINE ], client_returning([ item(0, quantity: "1", name: "lemon") ]))
    second_client = client_returning([])

    result = parse([ LINE ], second_client)

    assert_equal "lemon", result[LINE][:ingredient_name]
    assert_empty second_client.calls
  end

  def test_no_lines_makes_no_request
    client = client_returning([])

    assert_equal({}, parse([], client))
    assert_empty client.calls
  end

  private

  def parse(lines, client)
    RecipeImports::AiParseIngredients.call(lines, unit_lookup: @lookup, cache: @cache, client: client)
  end

  def client_returning(items)
    FakeClient.new(Base::Result.new(data: { ingredients: items }.to_json, success: true, error_message: nil))
  end

  def item(index, quantity: "", unit: "", name: "", notes: "", packaging_form: "", preparation_style: "")
    {
      line_index: index, quantity: quantity, unit: unit, name: name, notes: notes,
      packaging_form: packaging_form, preparation_style: preparation_style
    }
  end
end
