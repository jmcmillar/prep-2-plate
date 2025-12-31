class OfferingPricePoint < ApplicationRecord
  belongs_to :offering

  validates :serving_size, presence: true, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: :offering_id }
  validates :price, presence: true, numericality: { greater_than: 0 }

  # Ransack
  def self.ransackable_attributes(auth_object = nil)
    ["serving_size", "price"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["offering"]
  end
end
