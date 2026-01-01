class Vendors::Offerings::IndexFacade < BaseFacade
  def menu
    :main_menu
  end

  def active_key
    :meal_prep
  end

  def nav_resource
    nil
  end

  def vendor
    @vendor ||= Vendor.find(params[:vendor_id])
  end

  def base_collection
    @offerings ||= vendor.offerings.includes(:offering_price_points, :meal_types).order(featured: :desc, created_at: :desc)
      .filtered_by_meal_types(@params[:meal_type_ids])
  end

  def featured_offerings
    @featured_offerings ||= base_collection.featured.limit(6)
  end

  def vendor_name
    vendor.business_name
  end

  def page_title
    "#{vendor.business_name} - Meal Prep Offerings"
  end

  def page_description
    "Ready-to-cook meal prep options from #{vendor.business_name}"
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

  def pagy
    collection.pagy
  end

  def pagy_limit
    @pagy_limit ||= 9
  end

  def search_data
    SearchFormComponent::Data[
      form_url: [:admin, :recipes],
      query: collection.search_collection,
      label: "Search Name, Meal Types, Categories",
      field: :name_cont
    ]
  end

  def resource_facade_class
    Vendors::Offerings::ResourceFacade
  end

  def collection
    CollectionBuilder.new(base_collection, self)
  end
end
