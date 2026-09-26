require "test_helper"

class RecipeUtils::ParentheticalsTest < ActiveSupport::TestCase
  def test_separates_top_level_groups
    parens = RecipeUtils::Parentheticals.new("1 (14 oz) can tomatoes (drained)")

    assert_equal "1 can tomatoes", parens.text
    assert_equal [ "14 oz", "drained" ], parens.groups
  end

  def test_keeps_nested_groups_inside_their_parent
    parens = RecipeUtils::Parentheticals.new("1/2 onion (, sliced (white, brown, yellow))")

    assert_equal "1/2 onion", parens.text
    assert_equal [ "sliced (white, brown, yellow)" ], parens.groups
  end

  def test_unwraps_doubled_parentheses
    assert_equal [ "optional" ], RecipeUtils::Parentheticals.new("oil ((optional))").groups
  end

  def test_handles_unbalanced_input
    parens = RecipeUtils::Parentheticals.new("salt (to taste")

    assert_equal "salt", parens.text
    assert_equal [ "to taste" ], parens.groups
  end
end
