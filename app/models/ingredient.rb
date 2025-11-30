class Ingredient < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  belongs_to :ingredient_category, optional: true
  has_many :recipe_ingredients, dependent: :restrict_with_error, inverse_of: :ingredient
  delegate :name, to: :ingredient_category, prefix: true, allow_nil: true
  before_save :downcase_fields

  def downcase_fields
    self.name.downcase!
  end

  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
