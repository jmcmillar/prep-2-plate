class ShoppingList < ApplicationRecord
  validates :name, presence: true
  validates :user_id, presence: true

  has_many :shopping_list_items, dependent: :destroy
  belongs_to :user

  scope :for_user, ->(user) { where(user_id: user.id) }
  scope :current, -> { where(current: true) }
  scope :recent, -> { order(created_at: :desc) }

  accepts_nested_attributes_for :shopping_list_items, allow_destroy: true, reject_if: :all_blank
end
