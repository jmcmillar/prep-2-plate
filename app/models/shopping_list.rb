class ShoppingList < ApplicationRecord
  validates :name, presence: true
  validates :user_id, presence: true

  # Default association (active items only due to default scope)
  has_many :shopping_list_items, dependent: :destroy

  # All items including archived (for analytics)
  has_many :all_shopping_list_items,
           -> { unscope(where: :archived_at) },
           class_name: "ShoppingListItem",
           dependent: :destroy

  # Archived items only
  has_many :archived_shopping_list_items,
           -> { unscope(where: :archived_at).archived },
           class_name: "ShoppingListItem"

  belongs_to :user

  scope :for_user, ->(user) { where(user_id: user.id) }
  scope :current, -> { where(current: true) }
  scope :recent, -> { order(created_at: :desc) }

  accepts_nested_attributes_for :shopping_list_items, allow_destroy: true, reject_if: :all_blank
end
