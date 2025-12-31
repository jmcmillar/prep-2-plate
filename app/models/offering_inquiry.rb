class OfferingInquiry < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :offering
  has_one :vendor, through: :offering

  # Validations
  validates :serving_size, presence: true,
    numericality: { only_integer: true, greater_than: 0 }
  validates :quantity, presence: true,
    numericality: { only_integer: true, greater_than: 0 }
  validates :delivery_date, presence: true
  validates :status, inclusion: { in: %w[pending sent cancelled] }

  # Custom validations
  validate :delivery_date_is_future
  validate :serving_size_is_available

  # Scopes
  scope :pending, -> { where(status: "pending") }
  scope :sent, -> { where(status: "sent") }
  scope :cancelled, -> { where(status: "cancelled") }
  scope :for_user, ->(user) { where(user: user) }
  scope :recent, -> { order(created_at: :desc) }

  # Group pending inquiries by vendor
  def self.grouped_by_vendor
    pending
      .includes(offering: :vendor)
      .group_by { |inquiry| inquiry.offering.vendor }
  end

  # State transitions
  def mark_as_sent!
    update!(status: "sent", sent_at: Time.current)
  end

  def cancel!
    update!(status: "cancelled")
  end

  # Convenience methods
  def pending?
    status == "pending"
  end

  def sent?
    status == "sent"
  end

  def cancelled?
    status == "cancelled"
  end

  def estimated_price
    return nil unless offering.present? && serving_size.present?

    offering.price_for_servings(serving_size)
  end

  private

  def delivery_date_is_future
    return if delivery_date.blank?

    if delivery_date <= Date.today
      errors.add(:delivery_date, "must be in the future")
    end
  end

  def serving_size_is_available
    return if serving_size.blank? || offering.blank?

    unless offering.available_serving_sizes.include?(serving_size)
      errors.add(:serving_size, "is not available for this offering")
    end
  end
end
