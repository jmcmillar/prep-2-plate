class ShoppingListItem < ApplicationRecord
  belongs_to :shopping_list, counter_cache: true, touch: true
  validates :name, presence: true
end
