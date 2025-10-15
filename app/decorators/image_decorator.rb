class ImageDecorator < BaseDecorator
  def image
    return "" unless super.persisted?

    super
  end
end
