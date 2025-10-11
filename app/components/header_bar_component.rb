# frozen_string_literal: true

class HeaderBarComponent < ApplicationComponent
  DEFAULT_CLASSES = "px-6 py-3 bg-white border-b sticky top-0 z-10 flex justify-between items-center mb-6"
  renders_one :breadcrumb_collection, ->(collection) { render BreadcrumbComponent.with_collection(collection) }
  renders_one :icon_link_collection, ->(collection) { 
    render IconLinkComponent.with_collection(collection, class: "bg-secondary p-2 self-start rounded text-white") 
  }
  
  def initialize(title:)
    @title = title
  end
end
