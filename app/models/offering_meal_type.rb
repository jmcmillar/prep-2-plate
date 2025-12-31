class OfferingMealType < ApplicationRecord
  belongs_to :offering
  belongs_to :meal_type
end
