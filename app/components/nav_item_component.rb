# frozen_string_literal: true

class NavItemComponent < ApplicationComponent
  Data = Struct.new(:title, :path, :css, :icon)
  with_collection_parameter :nav_item

  def initialize(nav_item:)
    @nav_item = nav_item
  end
end
