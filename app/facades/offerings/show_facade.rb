class Offerings::ShowFacade < BaseFacade
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
    @vendor ||= offering.vendor
  end

  def offering
    @offering ||= Offering.active_vendor
                          .includes(:vendor, :offering_ingredients, :offering_price_points, :meal_types)
                          .find(@params[:id])
  end

  def ingredients
    @ingredients ||= IngredientFullNameDecorator.decorate_collection(
      offering.offering_ingredients.includes(:ingredient, :measurement_unit)
    )
  end

  def price_points
    @price_points ||= offering.offering_price_points.order(:serving_size)
  end

  def selected_serving_size
    @params[:serving_size]&.to_i || price_points.first&.serving_size
  end

  # Request quote methods
  def current_inquiry
    return nil unless user&.persisted?
    @current_inquiry ||= user.offering_inquiries.pending.find_by(offering: offering)
  end

  def already_selected?
    current_inquiry.present?
  end

  def new_offering_inquiry
    @new_offering_inquiry ||= OfferingInquiry.new(
      offering: offering,
      serving_size: selected_serving_size,
      delivery_date: 7.days.from_now.to_date,
      quantity: 1
    )
  end

  def show_request_quote?
    user&.persisted?
  end

  def offering_image
    safe_attachment(offering.image, '').url
  end

  def has_offering_image?
    offering.image.attached?
  end

  def has_description?
    offering.description.present?
  end

  def has_ingredients?
    ingredients.any?
  end

  def has_price_points?
    price_points.any?
  end

  def has_meal_types?
    offering.meal_types.any?
  end

  def vendor_logo
    safe_attachment(offering.vendor.logo, '').url
  end

  def has_vendor_logo?
    offering.vendor.logo.attached?
  end

  def has_vendor_description?
    offering.vendor.description.present?
  end
end
