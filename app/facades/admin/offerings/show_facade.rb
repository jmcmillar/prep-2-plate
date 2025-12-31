class Admin::Offerings::ShowFacade < Base::Admin::ShowFacade
  def offering
    @offering ||= Offering.includes(:vendor, :offering_ingredients, :offering_price_points, :meal_types).find(@params[:id])
  end

  def active_key
    :admin_offerings
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :vendors]),
      BreadcrumbComponent::Data.new("Vendors", [:admin, :vendors]),
      BreadcrumbComponent::Data.new(offering.vendor.business_name, [:admin, offering.vendor]),
      BreadcrumbComponent::Data.new("Offerings", [:admin, offering.vendor, :offerings]),
      BreadcrumbComponent::Data.new(offering.name)
    ]
  end

  def header_actions
    [edit_action_data]
  end

  def edit_action_data
    IconLinkComponent::Data[
      [:edit, :admin, offering],
      :edit,
      "Edit Offering"
    ]
  end

  def ingredients
    @ingredients ||= offering.offering_ingredients.includes(:ingredient, :measurement_unit)
  end

  def price_points
    @price_points ||= offering.offering_price_points.order(:serving_size)
  end

  def featured_badge
    if offering.featured?
      BadgeComponent::Data.new(text: "Yes", scheme: :featured)
    else
      BadgeComponent::Data.new(text: "No", scheme: :muted)
    end
  end
end
