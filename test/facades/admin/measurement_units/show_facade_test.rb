require "test_helper"

class Admin::MeasurementUnits::ShowFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @unit = measurement_units(:one)
    @facade = Admin::MeasurementUnits::ShowFacade.new(@admin, { id: @unit.id })
  end

  def test_measurement_unit
    assert_equal @unit, @facade.measurement_unit
  end

  def test_active_key
    assert_equal :admin_measurement_units, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Measurement Units", trail[1].text
  end

  def test_edit_action_data
    action = @facade.edit_action_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal "Measurement Unit", action.label
  end
end
