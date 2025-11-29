require "test_helper"

class Admin::MeasurementUnitAliases::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @unit = measurement_units(:one)
    @facade = Admin::MeasurementUnitAliases::NewFacade.new(@admin, { measurement_unit_id: @unit.id })
  end

  def test_measurement_unit_alias
    alias_record = @facade.measurement_unit_alias
    
    assert_kind_of MeasurementUnitAlias, alias_record
    assert alias_record.new_record?
  end

  def test_active_key
    assert_equal :admin_measurement_units, @facade.active_key
  end

  def test_measurement_unit
    assert_equal @unit, @facade.measurement_unit
  end

  def test_form_url
    assert_equal [:admin, @unit, :measurement_unit_aliases], @facade.form_url
  end

  def test_cancel_path
    assert_equal [:admin, @unit, :measurement_unit_aliases], @facade.cancel_path
  end
end
