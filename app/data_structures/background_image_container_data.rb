BackgroundImageContainerData = Data.define(
  :image,
  :position,
  :size,
  :repeat,
  :overlay,
  :html_options
) do
  def initialize(image:, position: "center center", size: "cover", repeat: "no-repeat", overlay: true, html_options: {})
    super
  end
end
