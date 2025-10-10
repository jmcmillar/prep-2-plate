class BackgroundImageData < Struct.new(
  :repeat,
  :size,
  :position,
  :overlay,
  keyword_init: true
)

  def initialize(*)
    super
    self.overlay ||= false
    self.repeat ||= "no-repeat"
    self.size ||= "cover"
    self.position ||= "center top"
  end
end
