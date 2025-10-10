require "test_helper"

class MeasurementUnitAliasTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:measurement_unit)
  end

  context "validations" do
    should validate_presence_of(:name)
    should validate_uniqueness_of(:name)
  end
end
