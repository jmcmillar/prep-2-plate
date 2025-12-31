class Offerings::ShowFacade < BaseFacade
  def layout
    Layout.new(menu, active_key, nav_resource)
  end

  def menu
    :main_menu
  end

  def active_key
    :meal_prep
  end

  def nav_resource
    nil
  end

  def offering
    @offering ||= Offering.active_vendor
                          .includes(:vendor, :offering_ingredients, :offering_price_points, :meal_types)
                          .find(@params[:id])
  end

  def ingredients
    @ingredients ||= offering.offering_ingredients.includes(:ingredient, :measurement_unit)
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
end
