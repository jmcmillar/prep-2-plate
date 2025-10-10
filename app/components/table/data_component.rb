# frozen_string_literal: true
class Table::DataComponent < ViewComponent::Base
  def initialize(data)
    @data = data
  end

  def call
    @data
  end
end