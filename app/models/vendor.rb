class Vendor < ApplicationRecord
  # Associations
  has_many :offerings, dependent: :destroy

  # Active Storage
  has_one_attached :logo

  # Validations
  validates :business_name, presence: true, uniqueness: true
  validates :contact_name, presence: true
  validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, inclusion: { in: %w[active inactive] }
  validates :phone_number, format: { with: /\A[\d\s\-\(\)\.+]+\z/, allow_blank: true }, length: { minimum: 10, maximum: 20, allow_blank: true }

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :inactive, -> { where(status: "inactive") }

  # State management
  def activate!
    update!(status: "active")
  end

  def deactivate!
    update!(status: "inactive")
  end

  def active?
    status == "active"
  end

  # Ransack
  def self.ransackable_attributes(auth_object = nil)
    ["business_name", "contact_name", "contact_email", "status", "city", "state"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["offerings"]
  end
end
