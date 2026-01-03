class ShoppingListItem < ApplicationRecord
  # Scopes for archiving
  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { unscope(where: :archived_at).where.not(archived_at: nil) }

  # Default scope to only show active items
  default_scope { active }

  belongs_to :shopping_list, counter_cache: true, touch: true
  belongs_to :ingredient, optional: true

  validates :name, presence: true
  validates :brand, length: { maximum: 255 }, allow_blank: true
  validates :packaging_form,
            inclusion: { in: Ingredient::PACKAGING_FORMS.keys.map(&:to_s), allow_nil: true, allow_blank: true }
  validates :preparation_style,
            inclusion: { in: Ingredient::PREPARATION_STYLES.keys.map(&:to_s), allow_nil: true, allow_blank: true }

  # Archive functionality
  def archive!
    return false if archived?

    transaction do
      update!(archived_at: Time.current)
      # Manually decrement counter cache since default scope changes
      shopping_list.class.decrement_counter(:shopping_list_items_count, shopping_list.id)
    end
  end

  def archived?
    archived_at.present?
  end
end
