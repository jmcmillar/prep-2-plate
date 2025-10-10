# frozen_string_literal: true

class BreadcrumbComponent < ApplicationComponent
  class Data < Struct.new(:text, :path)
  end
  
  def initialize(breadcrumb:, breadcrumb_iteration:,**options)
    @iteration = breadcrumb_iteration
    @text, @path = *breadcrumb
    @classes = options[:class]
  end

  def call
    (@path.present? ? crumb_link : crumb_text).concat separator
  end

  def separator
    return if @iteration.last?

    tag.span(class: "text-gray-500 font-bold mx-2 text-sm") { "/"}
  end

  def crumb_link
    link_to(
      @text,
      @path,
      class: class_names("text-primary font-bold hover:text-blue-800 text-sm", @classes)
    )
  end

  def crumb_text
    tag.span(@text, class: class_names("text-gray-500 font-bold text-sm", @classes))
  end
end
