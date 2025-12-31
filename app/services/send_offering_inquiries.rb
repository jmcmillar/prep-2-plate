class SendOfferingInquiries
  include Service

  Result = Struct.new(:success?, :vendor_count, :error, keyword_init: true)

  def initialize(user)
    @user = user
  end

  def call
    pending_inquiries = @user.offering_inquiries.pending.includes(offering: :vendor)

    return Result.new(success?: false, vendor_count: 0, error: "No pending inquiries to send") if pending_inquiries.empty?

    # Validate all inquiries before sending any emails
    invalid_inquiries = pending_inquiries.reject(&:valid?)
    if invalid_inquiries.any?
      return Result.new(
        success?: false,
        vendor_count: 0,
        error: "Some selections have errors. Please review and fix them."
      )
    end

    # Check for offerings that no longer exist
    missing_offerings = pending_inquiries.select { |i| i.offering.nil? }
    if missing_offerings.any?
      missing_offerings.each(&:cancel!)
      return Result.new(
        success?: false,
        vendor_count: 0,
        error: "Some offerings are no longer available. They have been removed from your selections."
      )
    end

    # Group inquiries by vendor
    grouped = pending_inquiries.group_by { |inquiry| inquiry.offering.vendor }

    # Send emails to vendors (only active vendors)
    active_vendor_count = 0
    grouped.each do |vendor, inquiries|
      next unless vendor.active?

      OfferingInquiriesMailer.vendor_inquiry(
        vendor: vendor,
        user: @user,
        inquiries: inquiries
      ).deliver_later

      active_vendor_count += 1
    end

    # Send confirmation to user
    # Convert hash to array of arrays to make it serializable for ActiveJob
    active_grouped = grouped.select { |vendor, _| vendor.active? }.to_a
    OfferingInquiriesMailer.user_confirmation(
      user: @user,
      grouped_inquiries: active_grouped
    ).deliver_later

    # Mark all inquiries as sent
    pending_inquiries.each(&:mark_as_sent!)

    Result.new(success?: true, vendor_count: active_vendor_count, error: nil)
  rescue StandardError => e
    Rails.logger.error "SendOfferingInquiries error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    Result.new(success?: false, vendor_count: 0, error: "An error occurred. Please try again.")
  end
end
