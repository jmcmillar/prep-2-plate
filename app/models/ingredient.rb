class Ingredient < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  has_many :recipe_ingredients, dependent: :restrict_with_error, inverse_of: :ingredient
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
