class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  has_many :user_recipes, dependent: :destroy
  has_many :recipe_favorites, dependent: :destroy
  has_many :recipes, through: :recipe_favorites
  has_many :allowlisted_jwts, dependent: :destroy
  has_many :user_meal_plans, dependent: :destroy
  has_many :meal_plans, through: :user_meal_plans
  has_many :shopping_lists, dependent: :destroy
  has_many :shopping_list_items, through: :shopping_lists
end
