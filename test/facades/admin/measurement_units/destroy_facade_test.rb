require "test_helper"

class Admin::MeasurementUnits::DestroyFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @unit = measurement_units(:one)
    @facade = Admin::MeasurementUnits::DestroyFacade.new(@admin, { id: @unit.id })
  end

  def test_measurement_unit
    assert_equal @unit, @facade.measurement_unit
  end
end
