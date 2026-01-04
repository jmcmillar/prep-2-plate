# frozen_string_literal: true

class BackgroundImageContainerComponent < ApplicationComponent
  def initialize(image:, **options)
    @image = image
    @settings = options[:settings] || BackgroundImageData.new
    @classes = class_names("relative text-white", options[:class])
    @html_options = extract_html_from_options(options)
  end

  private

  def background_image_attributes
    "background-image: url(#{url_for(@image)});
    background-color: #686A6B;
    background-repeat: #{@settings.repeat};
    background-size: #{@settings.size};
    background-position: #{@settings.position};"
  end
end
