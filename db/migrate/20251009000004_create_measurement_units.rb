class CreateMeasurementUnits < ActiveRecord::Migration[7.2]
  def change
    create_table :measurement_units do |t|
      t.string :name

      t.timestamps
    end
  end
end