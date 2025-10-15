class DatabaseView < ApplicationRecord
  self.abstract_class = true
  def readonly?
    true
  end
end
