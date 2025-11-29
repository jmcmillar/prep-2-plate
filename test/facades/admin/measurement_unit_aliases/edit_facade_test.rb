require "test_helper"

class Admin::MeasurementUnitAliases::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @unit = measurement_units(:one)
    @alias = @unit.measurement_unit_aliases.create!(name: "test alias")
    @facade = Admin::MeasurementUnitAliases::EditFacade.new(@admin, { id: @alias.id })
  end

  def test_measurement_unit_alias
    assert_equal @alias, @facade.measurement_unit_alias
  end

  def test_active_key
    assert_equal :admin_measurement_units, @facade.active_key
  end

  def test_measurement_unit
    assert_equal @unit, @facade.measurement_unit
  end

  def test_form_url
    assert_equal [:admin, @alias], @facade.form_url
  end

  def test_cancel_path
    assert_equal [:admin, @unit, :measurement_unit_aliases], @facade.cancel_path
  end
end
