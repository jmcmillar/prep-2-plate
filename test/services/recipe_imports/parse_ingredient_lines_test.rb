require "test_helper"

class RecipeImports::ParseIngredientLinesTest < ActiveSupport::TestCase
  include MeasurementUnitHelper

  class RecordingAiParser
    attr_reader :received

    def initialize(results)
      @results = results
    end

    def call(lines, **)
      @received = lines
      @results
    end
  end

  def setup
    create_parser_units
  end

  def test_uses_rule_results_when_ai_disabled
    results = RecipeImports::ParseIngredientLines.call([ "2 cups flour", "", "3 eggs" ], ai_enabled: false)

    assert_equal %w[flour egg], results.map { |result| result[:ingredient_name] }
  end

  def test_sends_only_low_confidence_lines_to_ai
    ai = RecordingAiParser.new({})

    RecipeImports::ParseIngredientLines.call([ "2 cups flour", "Juice of 1 lemon" ], ai_parser: ai, ai_enabled: true)

    assert_equal [ "Juice of 1 lemon" ], ai.received
  end

  def test_ai_results_replace_rule_results_in_order
    ai_result = { quantity: "1", measurement_unit_id: nil, ingredient_name: "lemon", packaging_form: nil,
                  preparation_style: nil, ingredient_notes: "juiced" }
    ai = RecordingAiParser.new("Juice of 1 lemon" => ai_result)

    results = RecipeImports::ParseIngredientLines.call([ "Juice of 1 lemon", "2 cups flour" ], ai_parser: ai, ai_enabled: true)

    assert_equal %w[lemon flour], results.map { |result| result[:ingredient_name] }
  end
end
