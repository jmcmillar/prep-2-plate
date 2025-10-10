class UserMealPlan < ApplicationRecord
  belongs_to :user
  belongs_to :meal_plan, dependent: :destroy

  accepts_nested_attributes_for :meal_plan
end
