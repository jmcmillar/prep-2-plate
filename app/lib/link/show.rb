class Link::Show < Link::Action
  private

  def action
    { action: :show, id: @id }
  end

  def icon
    :eye
  end

  def label_text
    "Show"
  end

  def html_options
    { class: "mx-2 text-gray-600" }
  end
end
