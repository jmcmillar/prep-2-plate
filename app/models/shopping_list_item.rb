class ShoppingListItem < ApplicationRecord
  belongs_to :shopping_list, touch: true
  validates :name, presence: true
end
