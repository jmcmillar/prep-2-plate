require "test_helper"

class Admin::MeasurementUnits::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @measurement_unit = measurement_units(:one)
    @facade = Admin::MeasurementUnits::EditFacade.new(@user, { id: @measurement_unit.id })
  end

  def test_measurement_unit
    assert_equal @measurement_unit, @facade.measurement_unit
  end

  def test_active_key
    assert_equal :admin_measurement_units, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Measurement Units", trail[1].text
    assert_equal "Edit", trail[2].text
  end
end
