class OfferingInquiries::IndexFacade < BaseFacade
  def initialize(user, params)
    super
    raise Pundit::NotAuthorizedError unless authorized?
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

  def offering_inquiries
    @offering_inquiries ||= user.offering_inquiries
      .pending
      .includes(offering: [:vendor, :offering_price_points, :image_attachment])
      .recent
  end

  def grouped_by_vendor
    @grouped_by_vendor ||= offering_inquiries.group_by { |inquiry| inquiry.offering.vendor }
  end

  def total_count
    offering_inquiries.count
  end

  def has_inquiries?
    total_count > 0
  end

  def send_button_data
    ButtonLinkComponent::Data[
      "Send All Inquiries",
      Rails.application.routes.url_helpers.batch_send_offering_inquiries_path,
      "paper-plane",
      :primary,
      {
        method: :post,
        data: {
          turbo_method: :post,
          turbo_confirm: "Send inquiries to #{grouped_by_vendor.count} vendor(s)?"
        }
      }
    ]
  end

  def status_badge_for(inquiry)
    scheme = case inquiry.status
    when "pending" then :default
    when "sent" then :success
    when "cancelled" then :muted
    else :default
    end

    BadgeComponent::Data.new(
      text: inquiry.status.titleize,
      scheme: scheme
    )
  end

  private

  def authorized?
    Base::AuthenticatedPolicy.new(user, nil).index?
  end
end
