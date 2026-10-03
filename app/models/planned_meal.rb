# One entry on a user's meal planner calendar: a recipe, or a placeholder
# like eating out that needs no recipe and adds nothing to shopping lists.
class PlannedMeal < ApplicationRecord
  KINDS = %w[recipe eat_out leftovers skip].freeze

  belongs_to :user
  belongs_to :recipe, optional: true

  validates :date, presence: true
  validates :kind, inclusion: { in: KINDS }
  validates :recipe, presence: true, if: :recipe_kind?
  validates :recipe_id, absence: true, unless: :recipe_kind?
  validate :recipe_visible_to_user, if: -> { recipe_kind? && recipe_id.present? }

  scope :ordered, -> { order(:date, :position) }

  def recipe_kind?
    kind == "recipe"
  end

  private

  def recipe_visible_to_user
    errors.add(:recipe, "not found") unless Recipe.visible_to(user).exists?(recipe_id)
  end
end
