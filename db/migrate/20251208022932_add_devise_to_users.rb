# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[8.0]
  def up
    change_table :users do |t|
      ## Database authenticatable
      # email_address already exists - will rename below
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false
      t.string   :unlock_token
      t.datetime :locked_at
    end

    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    add_index :users, :unlock_token,         unique: true

    # Rename email_address to email (Devise convention)
    rename_column :users, :email_address, :email

    # Migrate password_digest to encrypted_password
    User.reset_column_information
    User.find_each do |user|
      # Copy bcrypt hash from password_digest to encrypted_password
      digest = user.read_attribute(:password_digest)
      user.update_column(:encrypted_password, digest) if digest.present?
    end

    # Remove old password_digest column
    remove_column :users, :password_digest
  end

  def down
    # Rename email back to email_address
    rename_column :users, :email, :email_address

    # Add back password_digest column
    add_column :users, :password_digest, :string, null: false, default: ""

    # Migrate encrypted_password back to password_digest
    User.reset_column_information
    User.find_each do |user|
      encrypted = user.read_attribute(:encrypted_password)
      user.update_column(:password_digest, encrypted) if encrypted.present?
    end

    # Remove Devise columns
    remove_column :users, :encrypted_password
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
    remove_column :users, :remember_created_at
    remove_column :users, :sign_in_count
    remove_column :users, :current_sign_in_at
    remove_column :users, :last_sign_in_at
    remove_column :users, :current_sign_in_ip
    remove_column :users, :last_sign_in_ip
    remove_column :users, :confirmation_token
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_sent_at
    remove_column :users, :unconfirmed_email
    remove_column :users, :failed_attempts
    remove_column :users, :unlock_token
    remove_column :users, :locked_at

    # Remove indexes
    remove_index :users, :reset_password_token
    remove_index :users, :confirmation_token
    remove_index :users, :unlock_token
  end
end
