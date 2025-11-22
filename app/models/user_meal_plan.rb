class UserMealPlan < ApplicationRecord
  belongs_to :user
  belongs_to :meal_plan, dependent: :destroy

  validates :user_id, presence: true, uniqueness: { scope: :meal_plan_id }
  validates :meal_plan_id, presence: true

  accepts_nested_attributes_for :meal_plan, reject_if: :all_blank, allow_destroy: true
end
