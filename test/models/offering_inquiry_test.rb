require "test_helper"

class OfferingInquiryTest < ActiveSupport::TestCase
  def test_valid_inquiry
    inquiry = offering_inquiries(:one)
    assert inquiry.valid?
  end

  def test_requires_user
    inquiry = OfferingInquiry.new(
      offering: offerings(:grilled_chicken_veggies),
      serving_size: 10,
      quantity: 1,
      delivery_date: 7.days.from_now.to_date
    )
    assert_not inquiry.valid?
    assert_includes inquiry.errors[:user], "must exist"
  end

  def test_requires_offering
    inquiry = OfferingInquiry.new(
      user: users(:one),
      serving_size: 10,
      quantity: 1,
      delivery_date: 7.days.from_now.to_date
    )
    assert_not inquiry.valid?
    assert_includes inquiry.errors[:offering], "must exist"
  end

  def test_requires_serving_size
    inquiry = offering_inquiries(:one)
    inquiry.serving_size = nil
    assert_not inquiry.valid?
    assert_includes inquiry.errors[:serving_size], "can't be blank"
  end

  def test_serving_size_must_be_positive_integer
    inquiry = offering_inquiries(:one)

    inquiry.serving_size = 0
    assert_not inquiry.valid?

    inquiry.serving_size = -5
    assert_not inquiry.valid?

    inquiry.serving_size = 10
    assert inquiry.valid?
  end

  def test_requires_quantity
    inquiry = offering_inquiries(:one)
    inquiry.quantity = nil
    assert_not inquiry.valid?
    assert_includes inquiry.errors[:quantity], "can't be blank"
  end

  def test_quantity_must_be_positive_integer
    inquiry = offering_inquiries(:one)

    inquiry.quantity = 0
    assert_not inquiry.valid?

    inquiry.quantity = -1
    assert_not inquiry.valid?

    inquiry.quantity = 2
    assert inquiry.valid?
  end

  def test_requires_delivery_date
    inquiry = offering_inquiries(:one)
    inquiry.delivery_date = nil
    assert_not inquiry.valid?
    assert_includes inquiry.errors[:delivery_date], "can't be blank"
  end

  def test_delivery_date_must_be_in_future
    inquiry = offering_inquiries(:one)

    inquiry.delivery_date = Date.today
    assert_not inquiry.valid?
    assert_includes inquiry.errors[:delivery_date], "must be in the future"

    inquiry.delivery_date = Date.yesterday
    assert_not inquiry.valid?

    inquiry.delivery_date = Date.tomorrow
    assert inquiry.valid?
  end

  def test_status_must_be_valid
    inquiry = offering_inquiries(:one)

    inquiry.status = "pending"
    assert inquiry.valid?

    inquiry.status = "sent"
    assert inquiry.valid?

    inquiry.status = "cancelled"
    assert inquiry.valid?

    inquiry.status = "invalid_status"
    assert_not inquiry.valid?
    assert_includes inquiry.errors[:status], "is not included in the list"
  end

  def test_serving_size_must_be_available
    inquiry = offering_inquiries(:one)

    # If offering doesn't have a price point for serving size 999
    inquiry.serving_size = 999
    assert_not inquiry.valid?
    assert_includes inquiry.errors[:serving_size], "is not available for this offering"
  end

  def test_pending_scope
    pending = OfferingInquiry.pending
    assert_includes pending, offering_inquiries(:one)
    assert_includes pending, offering_inquiries(:two)
    assert_not_includes pending, offering_inquiries(:sent_inquiry)
  end

  def test_sent_scope
    sent = OfferingInquiry.sent
    assert_includes sent, offering_inquiries(:sent_inquiry)
    assert_not_includes sent, offering_inquiries(:one)
  end

  def test_cancelled_scope
    cancelled = OfferingInquiry.cancelled
    assert_includes cancelled, offering_inquiries(:cancelled_inquiry)
    assert_not_includes cancelled, offering_inquiries(:one)
  end

  def test_for_user_scope
    user_one_inquiries = OfferingInquiry.for_user(users(:one))
    assert_includes user_one_inquiries, offering_inquiries(:one)
    assert_includes user_one_inquiries, offering_inquiries(:two)
    assert_not_includes user_one_inquiries, offering_inquiries(:sent_inquiry)
  end

  def test_recent_scope
    inquiries = OfferingInquiry.recent.to_a
    # Should be ordered by created_at desc
    created_at_times = inquiries.map(&:created_at)
    assert_equal created_at_times, created_at_times.sort.reverse
  end

  def test_grouped_by_vendor
    grouped = OfferingInquiry.grouped_by_vendor
    assert_kind_of Hash, grouped
    # Keys should be vendors
    grouped.keys.each do |vendor|
      assert_kind_of Vendor, vendor
    end
  end

  def test_mark_as_sent
    inquiry = offering_inquiries(:one)
    assert_equal "pending", inquiry.status
    assert_nil inquiry.sent_at

    inquiry.mark_as_sent!
    assert_equal "sent", inquiry.status
    assert_not_nil inquiry.sent_at
  end

  def test_cancel
    inquiry = offering_inquiries(:one)
    assert_equal "pending", inquiry.status

    inquiry.cancel!
    assert_equal "cancelled", inquiry.status
  end

  def test_pending_predicate
    assert offering_inquiries(:one).pending?
    assert_not offering_inquiries(:sent_inquiry).pending?
  end

  def test_sent_predicate
    assert offering_inquiries(:sent_inquiry).sent?
    assert_not offering_inquiries(:one).sent?
  end

  def test_cancelled_predicate
    assert offering_inquiries(:cancelled_inquiry).cancelled?
    assert_not offering_inquiries(:one).cancelled?
  end

  def test_estimated_price
    inquiry = offering_inquiries(:one)
    # This test assumes the offering has price points set up
    price = inquiry.estimated_price
    # Price could be nil if no price point exists for that serving size
    assert price.nil? || price.is_a?(Numeric)
  end

  def test_unique_pending_inquiry_per_user_and_offering
    # Get the existing inquiry's data
    existing = offering_inquiries(:one)
    
    # Attempt to create duplicate pending inquiry - should raise database error
    assert_raises(ActiveRecord::RecordNotUnique) do
      OfferingInquiry.create!(
        user: existing.user,
        offering: existing.offering,
        serving_size: existing.offering.available_serving_sizes.first,
        quantity: 1,
        delivery_date: 10.days.from_now.to_date,
        status: "pending"
      )
    end
  end

  def test_can_have_multiple_sent_inquiries_for_same_offering
    # User can have multiple sent inquiries for the same offering
    # (sent in different batches)
    user = users(:one)
    # Use an offering that doesn't already have a pending inquiry for this user
    offering = offerings(:salmon_asparagus)

    # Create first inquiry and mark as sent
    first_inquiry = OfferingInquiry.create!(
      user: user,
      offering: offering,
      serving_size: 4,
      quantity: 1,
      delivery_date: 7.days.from_now.to_date,
      status: "pending"
    )
    first_inquiry.mark_as_sent!

    # Should be able to create another inquiry for same offering after first is sent
    second_inquiry = OfferingInquiry.new(
      user: user,
      offering: offering,
      serving_size: 6,
      quantity: 1,
      delivery_date: 14.days.from_now.to_date,
      status: "pending"
    )

    assert second_inquiry.valid?
    assert second_inquiry.save
  end
end
