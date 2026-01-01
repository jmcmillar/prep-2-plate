class Offerings::IndexFacade < BaseFacade
  def menu
    :main_menu
  end

  def active_key
    :meal_prep
  end

  def nav_resource
    nil
  end

  def offerings
    @offerings ||= Offering.active_vendor.includes(:vendor, :offering_price_points, :meal_types).order(featured: :desc, created_at: :desc)
  end

  def featured_offerings
    @featured_offerings ||= offerings.featured.limit(6)
  end

  def page_title
    "Meal Prep Offerings"
  end

  def page_description
    "Ready-to-cook meal prep options from our trusted vendors"
  end

  def vendors_for_filter
    @vendors_for_filter ||= Vendor.active.order(:business_name)
  end
end
