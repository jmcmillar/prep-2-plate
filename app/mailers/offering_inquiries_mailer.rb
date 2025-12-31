class OfferingInquiriesMailer < ApplicationMailer
  # Send inquiry to vendor with all selected offerings
  def vendor_inquiry(vendor:, user:, inquiries:)
    @vendor = vendor
    @user = user
    @inquiries = inquiries.sort_by { |i| i.offering.name }

    mail(
      to: @vendor.contact_email,
      reply_to: @user.email,
      subject: "New Catering Inquiry from #{@user.first_name} #{@user.last_name}"
    )
  end

  # Send confirmation to user
  def user_confirmation(user:, grouped_inquiries:)
    @user = user
    @grouped_inquiries = grouped_inquiries
    @vendor_count = grouped_inquiries.count

    mail(
      to: @user.email,
      subject: "Your catering inquiries have been sent"
    )
  end
end
