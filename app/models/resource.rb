class Resource < ApplicationRecord
  has_one_attached :attachment

  validates :name, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end
end
