class CreateOfferingInquiries < ActiveRecord::Migration[8.0]
  def change
    create_table :offering_inquiries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :offering, null: false, foreign_key: true

      # Inquiry details
      t.integer :serving_size, null: false
      t.integer :quantity, default: 1, null: false
      t.date :delivery_date, null: false
      t.text :notes

      # State tracking
      t.string :status, default: "pending", null: false
      t.datetime :sent_at

      t.timestamps
    end

    # Prevent duplicate pending selections
    add_index :offering_inquiries, [:user_id, :offering_id, :status],
      unique: true,
      where: "status = 'pending'",
      name: "index_offering_inquiries_unique_pending"

    add_index :offering_inquiries, [:user_id, :status]
    add_index :offering_inquiries, [:user_id, :created_at]
    add_index :offering_inquiries, :status
  end
end
