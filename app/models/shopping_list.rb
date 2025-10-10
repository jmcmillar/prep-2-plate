class ShoppingList < ApplicationRecord
  validates :name, presence: true
  has_many :shopping_list_items, dependent: :destroy
  belongs_to :user

  accepts_nested_attributes_for :shopping_list_items, allow_destroy: true
end
