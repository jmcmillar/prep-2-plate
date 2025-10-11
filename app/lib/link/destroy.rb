class Link::Destroy < Link::Action
  private

  def action
    { action: :destroy, id: @id }
  end

  def icon
    :trash
  end

  def label_text
    "Delete"
  end

  def html_options
    { data: { turbo_confirm: 'Are you sure?' , turbo_method: :delete }, class: "mx-2 text-gray-600" }
  end
end
