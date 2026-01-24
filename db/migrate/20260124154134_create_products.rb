class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :barcode, null: false
      t.string :name, null: false
      t.string :brand
      t.string :quantity
      t.string :packaging
      t.json :raw_data

      t.timestamps
    end

    add_index :products, :barcode, unique: true
    add_index :products, :name
    add_index :products, :brand
  end
end
