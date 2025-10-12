# frozen_string_literal: true

class SectionCardComponent < ApplicationComponent
  renders_one :icon_link_collection, ->(collection) { 
    render IconLinkComponent.with_collection(collection, class: "mx-1 bg-secondary p-2 self-start rounded text-white") 
  }

  def initialize(title: nil, **options)
    @title = title
    @title_tag = options[:title_tag] || :h2
  end

  def title_section
    return unless @title

    content_tag(@title_tag, @title)
  end
end
