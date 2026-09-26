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
    @offerings ||= search.result
      .active_vendor
      .filtered_by_meal_types(params[:meal_type_ids])
      .includes(:vendor, :offering_price_points, :meal_types)
      .order(featured: :desc, created_at: :desc)
  end

  def search_data
    SearchFormComponent::Data[
      form_url: [ :offerings ],
      query: search,
      label: "Search Offerings",
      field: :name_cont
    ]
  end

  def meal_type_filter_data
    FilterComponent::Data.new(
      "Meal Types",
      "meal_type_ids[]",
      Rails.cache.fetch("meal_types_ordered", expires_in: 12.hours) do
        MealType.order(:name).to_a
      end
    )
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

  private

  def search
    @search ||= Offering.ransack(params[:q])
  end
end
