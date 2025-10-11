class Link::Action
  def initialize(id, label, controller = nil)
    @id = id
    @label = label
    @controller = controller
  end

  def self.to_data(...)
    self.new(...).to_data
  end

  def to_data
    return unless controller_instance.respond_to?(action[:action])
    ButtonLinkComponent::Data[label_text, path, icon, :light, html_options]
  end

  private

  def path
    action.merge controller
  end

  def controller
    @controller.present? ? { controller: @controller } : {}
  end

  def action
    {}
  end

  def icon
  end

  def label_text
  end

  def html_options
    {}
  end

  def controller_instance
    [@controller.classify.pluralize, "Controller"].join.safe_constantize.new
  end
end
