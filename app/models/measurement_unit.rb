class MeasurementUnit < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  has_many :recipe_ingredients, dependent: :restrict_with_error
  has_many :measurement_unit_aliases, dependent: :destroy
  before_save :downcase_fields

  def downcase_fields
    self.name.downcase!
  end
end
