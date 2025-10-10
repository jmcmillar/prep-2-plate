class ToggleFormComponent < ApplicationComponent
  Data = Struct.new(:path, :method, :label, :icon, :options)

  def initialize(data)
    @path = data.path
    @method = data.method
    @label = data.label
    @icon = data.icon
    @options = data.options || {}
  end

  def call
    button_to(
      icon,
      url_for(@path),
      method: @method,
      **@options
    )
  end

  def icon
    render IconComponent.new(@icon)
  end
end
