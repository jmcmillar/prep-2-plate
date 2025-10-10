class RecipeCategory < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  has_many :recipe_category_assignments, dependent: :destroy
  has_many :recipes, through: :recipe_category_assignments

  has_one_attached :image

  scope :filtered_by_ids, -> (ids) {
    return all if ids.blank?
    where(id: ids)
  }
  
  def downcase_fields
    self.name.downcase!
  end
end
