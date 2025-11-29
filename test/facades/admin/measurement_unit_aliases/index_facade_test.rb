require "test_helper"

class Admin::MeasurementUnitAliases::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @unit = measurement_units(:one)
    @alias = @unit.measurement_unit_aliases.create!(name: "test alias")
    @facade = Admin::MeasurementUnitAliases::IndexFacade.new(@admin, { measurement_unit_id: @unit.id })
  end

  def test_active_key
    assert_equal :admin_measurement_units, @facade.active_key
  end

  def test_measurement_unit
    assert_equal @unit, @facade.measurement_unit
  end

  def test_base_collection
    assert_includes @facade.base_collection, @alias
  end

  def test_new_action_data
    action = @facade.new_action_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal "New Measurement Unit Alias", action.label
  end

  def test_resource_facade_class
    assert_equal Admin::MeasurementUnitAliases::ResourceFacade, @facade.resource_facade_class
  end
end
