class Product < ApplicationRecord
  # Associations
  has_many :shopping_list_items, dependent: :nullify

  # Validations
  validates :barcode, presence: true, uniqueness: true
  validates :barcode, format: {
    with: /\A\d{8,14}\z/,
    message: "must be 8-14 digits"
  }
  validates :name, presence: true
  validates :brand, length: { maximum: 255 }, allow_blank: true

  # Scopes
  scope :by_brand, ->(brand) { where(brand: brand) }
  scope :recent, -> { order(created_at: :desc) }

  # Ransack
  def self.ransackable_attributes(auth_object = nil)
    ["barcode", "name", "brand", "quantity", "packaging", "created_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["shopping_list_items"]
  end
end
