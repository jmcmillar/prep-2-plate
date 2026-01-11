class UserShoppingItemPreference < ApplicationRecord
  belongs_to :user

  validates :item_name, presence: true
  validates :preferred_brand, presence: true
  validates :item_name, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :usage_count, numericality: { greater_than_or_equal_to: 1 }

  before_validation :normalize_item_name

  # Class method for finding preference by name (case-insensitive)
  def self.find_for_item(user_id, item_name)
    return nil if item_name.blank?

    where(user_id: user_id)
      .where("LOWER(item_name) = ?", item_name.to_s.downcase.strip)
      .first
  end

  # Record usage - updates usage_count and last_used_at
  def record_usage!
    increment!(:usage_count)
    touch(:last_used_at)
  end

  # Display context for UI
  def display_context
    "#{preferred_brand} #{item_name}"
  end

  private

  def normalize_item_name
    self.item_name = item_name.to_s.downcase.strip if item_name.present?
  end
end
