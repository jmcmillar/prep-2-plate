class Admin::Vendors::ResourceFacade
  def initialize(resource)
    @resource = resource
  end

  def self.headers
    [
      Table::DefaultHeaderComponent.new("Business Name"),
      Table::DefaultHeaderComponent.new("Contact"),
      Table::DefaultHeaderComponent.new("Status"),
      Table::DefaultHeaderComponent.new("Offerings")
    ]
  end

  def self.to_row(facade)
    Table::RowComponent.new(
      [
        facade.business_name,
        facade.contact_info,
        facade.status_badge,
        facade.offerings_count,
        facade.action
      ],
      id: facade.id
    )
  end

  def business_name
    Table::DataComponent.new(@resource.business_name)
  end

  def contact_info
    Table::DataComponent.new("#{@resource.contact_name} (#{@resource.contact_email})")
  end

  def status_badge
    scheme = case @resource.status
    when "active" then :success
    when "inactive" then :default
    else :default
    end

    badge_data = BadgeComponent::Data.new(
      text: @resource.status.titleize,
      scheme: scheme
    )

    BadgeComponent.new(badge_data: badge_data)
  end

  def offerings_count
    Table::DataComponent.new(@resource.offerings.count)
  end

  def action
    Table::ActionComponent.new(action_turbo_data)
  end

  def id
    ["vendor", @resource.id].join("_")
  end

  private

  def action_turbo_data
    TurboData[
      :table_actions,
      [:table_actions, label: @resource.business_name, id: @resource.id, controller_path: "admin/vendors"]
    ]
  end
end
