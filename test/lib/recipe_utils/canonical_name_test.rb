require "test_helper"

class RecipeUtils::CanonicalNameTest < ActiveSupport::TestCase
  EXPECTED = {
    "Eggs" => "egg",
    "tomatoes" => "tomato",
    "fresh blueberries" => "fresh blueberry",
    "olives" => "olive",
    "bay leaves" => "bay leaf",
    "peaches" => "peach",
    "cookies" => "cookie",
    "molasses" => "molasses",
    "hummus" => "hummus",
    "asparagus" => "asparagus",
    "grass" => "grass",
    "all-purpose flour" => "all-purpose flour",
    "confectioners' sugar" => "confectioners sugar",
    "baker's yeast" => "baker's yeast",
    "flour*" => "flour",
    "" => ""
  }.freeze

  def test_canonicalizes_ingredient_names
    EXPECTED.each do |input, expected|
      assert_equal expected, RecipeUtils::CanonicalName.call(input), "for #{input.inspect}"
    end
  end
end
