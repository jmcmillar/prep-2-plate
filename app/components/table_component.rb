# frozen_string_literal: true

class TableComponent < ApplicationComponent
  include Pagy::Frontend

  def initialize(headers, rows, pagy = nil)
    @header_data = headers
    @row_data = rows
    @pagy = pagy
  end
end
