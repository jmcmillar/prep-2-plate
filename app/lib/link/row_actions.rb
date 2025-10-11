class Link::RowActions
  def initialize(id:, label:, **options)
    @id = id
    @label = label
    @controller = options.fetch(:controller, nil)
  end

  def self.to_data(...)
    self.new(...).to_data
  end

  def to_data
    action_array
  end

  private

  def action_array
    [show_data, edit_data, destroy_data].compact
  end

  def show_data
    Link::Show.to_data(@id, @label, @controller)
  end

  def edit_data
    Link::Edit.to_data(@id, @label, @controller)
  end

  def destroy_data
    Link::Destroy.to_data(@id, @label, @controller)
  end
end
