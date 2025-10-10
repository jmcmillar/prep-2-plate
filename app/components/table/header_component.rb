# frozen_string_literal: true

class Table::HeaderComponent < ApplicationComponent
  DEFAULT_CLASSES = "border-b border-primary/40 bg-primary p-2 text-white text-left"

  def initialize(header:, header_iteration:, **options)
    @header = header
    @iteration = header_iteration
    options[:class] = class_names(DEFAULT_CLASSES, options[:class])
    @html_options = extract_html_from_options(options, key_list = %i[class])
  end

  def call
    tag.th(**@html_options.merge(colspan)) do
      render @header
    end
  end

  private

  def colspan
    @iteration.last? ? { colspan: 2 } : {}
  end
end
