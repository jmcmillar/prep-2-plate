class MeasurementUnitAlias < ApplicationRecord
  belongs_to :measurement_unit
  validates :name, presence: true
  validates_uniqueness_of :name
end
