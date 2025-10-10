class CreateMeasurementUnitAliases < ActiveRecord::Migration[7.2]
  def change
    create_table :measurement_unit_aliases do |t|
      t.references :measurement_unit, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end