class Offering < ApplicationRecord
  # Rich text and attachments
  has_rich_text :description
  has_one_attached :image

  # Associations
  belongs_to :vendor
  has_many :offering_ingredients, dependent: :destroy, inverse_of: :offering
  has_many :ingredients, through: :offering_ingredients
  has_many :measurement_units, through: :offering_ingredients
  has_many :offering_meal_types, dependent: :destroy
  has_many :meal_types, through: :offering_meal_types
  has_many :offering_price_points, dependent: :destroy
  has_many :offering_inquiries, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true
  validates :base_serving_size, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # Nested attributes
  accepts_nested_attributes_for :offering_ingredients,
    allow_destroy: true,
    reject_if: ->(attrs) { attrs["ingredient_id"].blank? && attrs["ingredient_name"].blank? }

  accepts_nested_attributes_for :offering_price_points,
    allow_destroy: true,
    reject_if: ->(attrs) { attrs["serving_size"].blank? || attrs["price"].blank? }

  # Scopes
  scope :featured, -> { where(featured: true) }
  scope :for_vendor, ->(vendor) { where(vendor: vendor) }
  scope :active_vendor, -> { joins(:vendor).where(vendors: { status: "active" }) }

  # Instance methods
  def price_for_servings(servings)
    offering_price_points.find_by(serving_size: servings)&.price
  end

  def available_serving_sizes
    offering_price_points.order(:serving_size).pluck(:serving_size)
  end

  def price_points_hash
    offering_price_points.pluck(:serving_size, :price).to_h
  end

  # Ransack
  def self.ransackable_attributes(auth_object = nil)
    ["name", "featured", "base_serving_size", "created_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["vendor", "meal_types", "ingredients"]
  end
end
