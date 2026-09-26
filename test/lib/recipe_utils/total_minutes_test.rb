require "test_helper"

class RecipeUtils::TotalMinutesTest < ActiveSupport::TestCase
  def test_prefers_total_time
    assert_equal 60, RecipeUtils::TotalMinutes.call(total_time: 60, prep_time: 10, cook_time: 20)
  end

  def test_falls_back_to_prep_plus_cook
    assert_equal 30, RecipeUtils::TotalMinutes.call(total_time: nil, prep_time: 10, cook_time: 20)
    assert_equal 20, RecipeUtils::TotalMinutes.call(total_time: 0, prep_time: nil, cook_time: 20)
  end

  def test_returns_nil_when_unknown
    assert_nil RecipeUtils::TotalMinutes.call({})
  end
end
