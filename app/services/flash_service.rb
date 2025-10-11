class FlashService
  include Service

  FlashSchemeData = Struct.new(:flash_type, :class, :icon)

  SCHEME_MAP = [
    FlashSchemeData.new(:alert, "bg-teal-100 border-teal-400 text-teal-700", :exclamation_triangle),
    FlashSchemeData.new(:notice, "bg-teal-100 border-teal-400 text-teal-700", :check_circle),
    FlashSchemeData.new(:success, "bg-teal-100 border-teal-400 text-teal-700", :check_circle),
    FlashSchemeData.new(:info, "bg-blue-100 border-blue-400 text-blue-700", :info_circle),
    FlashSchemeData.new(:error, "bg-[#f8d7da] border-red-400 text-[#721c24]", :exclamation_circle)
  ]

  def initialize(flash)
    @flash = flash.to_h.reduce(:merge)
    @view_context = ApplicationController.new.view_context
  end

  def call
    return unless @flash

    FlashComponent.new(
      scheme: scheme.class,
      icon: scheme.icon,
      message: message,
      dismiss: true
    ).render_in @view_context
  end

  private

  def scheme
    SCHEME_MAP.find { |flash_data| flash_data.flash_type == flash_type }
  end

  def flash_type
    @flash[0].to_sym
  end

  def dismissable?
    flash_type.in?(%i[info notice success])
  end

  def message
    @flash[1]
  end
end
