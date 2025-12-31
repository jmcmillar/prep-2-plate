class Admin::Offerings::ResourceFacade
  def initialize(resource)
    @resource = resource
  end

  def self.headers
    [
      Table::DefaultHeaderComponent.new("Name"),
      Table::DefaultHeaderComponent.new("Vendor"),
      Table::DefaultHeaderComponent.new("Price Points"),
      Table::DefaultHeaderComponent.new("Featured")
    ]
  end

  def self.to_row(facade)
    Table::RowComponent.new(
      [
        facade.name,
        facade.vendor_name,
        facade.price_points_count,
        facade.featured_badge,
        facade.action
      ],
      id: facade.id
    )
  end

  def name
    Table::DataComponent.new(@resource.name)
  end

  def vendor_name
    Table::DataComponent.new(@resource.vendor.business_name)
  end

  def price_points_count
    Table::DataComponent.new("#{@resource.offering_price_points.count} tiers")
  end

  def featured_badge
    badge_data = if @resource.featured?
      BadgeComponent::Data.new(text: "Featured", scheme: :featured)
    else
      BadgeComponent::Data.new(text: "—", scheme: :muted)
    end

    Table::DataComponent.new(BadgeComponent.new(badge_data: badge_data))
  end

  def action
    Table::ActionComponent.new(action_turbo_data)
  end

  def id
    ["offering", @resource.id].join("_")
  end

  private

  def action_turbo_data
    TurboData[
      :table_actions,
      [:table_actions, label: @resource.name, id: @resource.id, controller_path: "admin/offerings"]
    ]
  end
end
