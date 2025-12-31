class OfferingInquiries::NewFacade < BaseFacade
  def initialize(user, params)
    super
    raise Pundit::NotAuthorizedError unless authorized?
  end

  def offering
    @offering ||= Offering.active_vendor
      .includes(:offering_price_points, :vendor)
      .find(params[:offering_inquiry][:offering_id])
  end

  def offering_inquiry
    @offering_inquiry ||= OfferingInquiry.new(
      user: user,
      offering: offering,
      serving_size: default_serving_size,
      delivery_date: default_delivery_date
    )
  end

  private

  def default_serving_size
    params.dig(:offering_inquiry, :serving_size)&.to_i ||
      offering.offering_price_points.order(:serving_size).first&.serving_size
  end

  def default_delivery_date
    params.dig(:offering_inquiry, :delivery_date) || 7.days.from_now.to_date
  end

  def authorized?
    Base::AuthenticatedPolicy.new(user, nil).create?
  end
end
