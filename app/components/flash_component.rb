class FlashComponent < ViewComponent::Base
  include ApplicationHelper
  DEFAULT_CLASSES = "border px-4 py-3 rounded relative"

  def initialize(scheme:, icon:, message:, **options)
    @classes = class_names(DEFAULT_CLASSES, scheme)
    @message = message
    @icon =  icon
    @dismiss = options[:dismiss]
  end

  def flash_notice(&block)
    tag.div(class: @classes, role: "alert", data: set_data_attributes) do
      block&.call
    end
  end

  def set_data_attributes
    return unless @dismiss
    { controller: "flash-dismiss" }
  end
end