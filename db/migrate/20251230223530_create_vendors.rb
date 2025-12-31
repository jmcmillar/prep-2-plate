class CreateVendors < ActiveRecord::Migration[8.0]
  def change
    create_table :vendors do |t|
      t.string :business_name, null: false
      t.string :contact_name, null: false
      t.string :contact_email, null: false
      t.text :description
      t.string :phone_number
      t.string :website_url
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :vendors, :business_name, unique: true
    add_index :vendors, :status
  end
end
