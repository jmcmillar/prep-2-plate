class Table::DefaultHeaderComponent < ApplicationComponent
  def initialize(value)
    @value = value
  end

  def call
    @value
  end
end
