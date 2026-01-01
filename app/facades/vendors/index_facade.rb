class Vendors::IndexFacade < BaseFacade
  def menu
    :main_menu
  end

  def active_key
    :vendors
  end

  def nav_resource
    nil
  end

  def vendors
    @vendors ||= Vendor.active.order(:business_name)
  end

  def page_title
    "Meal Prep Vendors"
  end

  def page_description
    "Browse our trusted meal prep vendors offering fresh, ready-to-cook meals"
  end
end
