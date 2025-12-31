# Preview all emails at http://localhost:3000/rails/mailers/offering_inquiries_mailer
class OfferingInquiriesMailerPreview < ActionMailer::Preview
  def vendor_inquiry
    vendor = Vendor.active.first || Vendor.first
    user = User.first
    inquiries = OfferingInquiry.where(offering: vendor.offerings).limit(3)

    # Create sample inquiries if none exist
    if inquiries.empty?
      offering = vendor.offerings.first
      inquiries = [
        OfferingInquiry.new(
          user: user,
          offering: offering,
          serving_size: offering.available_serving_sizes.first || 10,
          quantity: 1,
          delivery_date: 7.days.from_now.to_date,
          notes: "Please deliver to the side entrance"
        )
      ]
    end

    OfferingInquiriesMailer.vendor_inquiry(
      vendor: vendor,
      user: user,
      inquiries: inquiries
    )
  end

  def user_confirmation
    user = User.first
    inquiries = OfferingInquiry.pending.includes(offering: :vendor).limit(5)

    # Create sample inquiries if none exist
    if inquiries.empty?
      vendor = Vendor.first
      offering = vendor.offerings.first
      inquiries = [
        OfferingInquiry.new(
          user: user,
          offering: offering,
          serving_size: offering.available_serving_sizes.first || 10,
          quantity: 1,
          delivery_date: 7.days.from_now.to_date
        )
      ]
    end

    grouped = inquiries.group_by { |i| i.offering.vendor }

    OfferingInquiriesMailer.user_confirmation(
      user: user,
      grouped_inquiries: grouped
    )
  end
end
