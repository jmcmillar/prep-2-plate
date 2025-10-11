class Link::Edit < Link::Action
  private

  def action
    { action: :edit, id: @id }
  end

  def icon
    :edit
  end

  def label_text
    "Edit"
  end

  def html_options
    { class: "mx-2 text-gray-600" }
  end
end
