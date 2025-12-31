class CreateOfferingPricePoints < ActiveRecord::Migration[8.0]
  def change
    create_table :offering_price_points do |t|
      t.references :offering, null: false, foreign_key: true
      t.integer :serving_size, null: false
      t.decimal :price, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :offering_price_points, [:offering_id, :serving_size], unique: true
  end
end
