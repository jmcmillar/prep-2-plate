class Table::IconActionsComponent < ViewComponent::Base
  def initialize(actions)
    @actions = actions
  end

  def call
    tag.div(class: "flex justify-end") do
      render IconLinkComponent.with_collection(@actions)
    end
  end
end
