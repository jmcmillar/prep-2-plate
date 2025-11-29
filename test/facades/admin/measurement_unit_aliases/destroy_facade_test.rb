require "test_helper"

class Admin::MeasurementUnitAliases::DestroyFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @unit = measurement_units(:one)
    @alias = @unit.measurement_unit_aliases.create!(name: "test alias")
    @facade = Admin::MeasurementUnitAliases::DestroyFacade.new(@admin, { id: @alias.id })
  end

  def test_measurement_unit_alias
    assert_equal @alias, @facade.measurement_unit_alias
  end
end
