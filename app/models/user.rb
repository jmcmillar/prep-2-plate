class User < ApplicationRecord
  # Devise modules for web authentication
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable

  # Keep Session model for API Bearer token authentication
  has_many :sessions, dependent: :destroy

  # Active Storage
  has_one_attached :image, dependent: :destroy

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true

  # Normalizations - updated to use :email instead of :email_address
  normalizes :email, with: ->(e) { e.strip.downcase }

  # Associations
  has_many :user_recipes, dependent: :destroy
  has_many :recipe_favorites, dependent: :destroy
  has_many :recipes, through: :recipe_favorites
  has_many :user_meal_plans, dependent: :destroy
  has_many :meal_plans, through: :user_meal_plans
  has_many :shopping_lists, dependent: :destroy
  has_many :shopping_list_items, through: :shopping_lists
  has_many :user_ingredient_preferences, dependent: :destroy
  has_many :offering_inquiries, dependent: :destroy

  # Scopes
  scope :active, -> { where(deactivated: false) }
  scope :deactivated, -> { where(deactivated: true) }

  # Override Devise method to ensure account isn't locked or deactivated
  def active_for_authentication?
    super && !locked_at && !deactivated?
  end

  # Custom message when account is locked or deactivated
  def inactive_message
    return :locked if locked_at
    return :deactivated if deactivated?
    super
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[first_name last_name email deactivated]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
