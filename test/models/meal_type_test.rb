require "test_helper"

class MealTypeTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_uniqueness_of(:name).case_insensitive
end
