class CreateOfferings < ActiveRecord::Migration[8.0]
  def change
    create_table :offerings do |t|
      t.references :vendor, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :base_serving_size, null: false, default: 2
      t.boolean :featured, default: false

      t.timestamps
    end

    add_index :offerings, [:vendor_id, :created_at]
    add_index :offerings, :featured
    add_index :offerings, :created_at
  end
end
