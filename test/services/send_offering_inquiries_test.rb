require "test_helper"

class SendOfferingInquiriesTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @user_one = users(:one)
    @user_two = users(:two)
    # Clear any existing inquiries to avoid conflicts
    OfferingInquiry.destroy_all
    # Clear email deliveries
    ActionMailer::Base.deliveries.clear
  end

  def test_successful_send_with_single_vendor
    # Create a pending inquiry
    offering = offerings(:grilled_chicken_veggies)
    inquiry = OfferingInquiry.create!(
      user: @user_one,
      offering: offering,
      serving_size: 10,
      quantity: 2,
      delivery_date: 1.week.from_now,
      notes: "Please include extra sauce"
    )

    result = nil
    perform_enqueued_jobs do
      result = SendOfferingInquiries.call(@user_one)
    end

    assert result.success?, "Expected success but got error: #{result.error}"
    assert_equal 1, result.vendor_count
    assert_nil result.error

    # Verify inquiry marked as sent
    assert_equal "sent", inquiry.reload.status
    assert_not_nil inquiry.sent_at

    # Verify emails sent (1 vendor + 1 user confirmation)
    assert_equal 2, ActionMailer::Base.deliveries.size
  end

  def test_successful_send_with_multiple_vendors
    # Create inquiries for two different vendors
    offering1 = offerings(:grilled_chicken_veggies) # healthy_meal_co
    offering2 = offerings(:protein_power_bowl) # fit_kitchen

    inquiry1 = OfferingInquiry.create!(
      user: @user_one,
      offering: offering1,
      serving_size: 10,
      quantity: 1,
      delivery_date: 1.week.from_now
    )

    inquiry2 = OfferingInquiry.create!(
      user: @user_one,
      offering: offering2,
      serving_size: 8,
      quantity: 2,
      delivery_date: 1.week.from_now
    )

    perform_enqueued_jobs do
      result = SendOfferingInquiries.call(@user_one)

      assert result.success?
      assert_equal 2, result.vendor_count
      assert_nil result.error
    end

    # Verify both inquiries marked as sent
    assert_equal "sent", inquiry1.reload.status
    assert_equal "sent", inquiry2.reload.status

    # Verify emails sent (2 vendors + 1 user confirmation)
    assert_equal 3, ActionMailer::Base.deliveries.size
  end

  def test_successful_send_with_multiple_offerings_same_vendor
    # Create two inquiries for the same vendor (healthy_meal_co)
    offering1 = offerings(:grilled_chicken_veggies)
    offering2 = offerings(:salmon_asparagus)

    assert_equal offering1.vendor, offering2.vendor, "Offerings should be from same vendor"

    inquiry1 = OfferingInquiry.create!(
      user: @user_one,
      offering: offering1,
      serving_size: 10,
      quantity: 1,
      delivery_date: 1.week.from_now
    )

    inquiry2 = OfferingInquiry.create!(
      user: @user_one,
      offering: offering2,
      serving_size: 6,
      quantity: 3,
      delivery_date: 1.week.from_now
    )

    perform_enqueued_jobs do
      result = SendOfferingInquiries.call(@user_one)

      assert result.success?
      assert_equal 1, result.vendor_count
      assert_nil result.error
    end

    # Verify both inquiries marked as sent
    assert_equal "sent", inquiry1.reload.status
    assert_equal "sent", inquiry2.reload.status

    # Verify emails sent (1 vendor with both offerings + 1 user confirmation)
    assert_equal 2, ActionMailer::Base.deliveries.size
  end

  def test_failure_when_no_pending_inquiries
    # User has no pending inquiries
    result = SendOfferingInquiries.call(@user_one)

    assert_not result.success?
    assert_equal 0, result.vendor_count
    assert_equal "No pending inquiries to send", result.error
  end

  def test_skips_inactive_vendors
    # Create inquiry for a vendor
    offering = offerings(:grilled_chicken_veggies)
    vendor = offering.vendor

    inquiry = OfferingInquiry.create!(
      user: @user_one,
      offering: offering,
      serving_size: 10,
      quantity: 1,
      delivery_date: 1.week.from_now
    )

    # Deactivate the vendor
    vendor.deactivate!

    perform_enqueued_jobs do
      result = SendOfferingInquiries.call(@user_one)

      assert result.success?
      assert_equal 0, result.vendor_count # No active vendors
      assert_nil result.error
    end

    # Verify inquiry still marked as sent
    assert_equal "sent", inquiry.reload.status

    # Verify only user confirmation sent, no vendor email
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal @user_one.email, ActionMailer::Base.deliveries.first.to.first
  end

  def test_sends_vendor_email_with_correct_content
    offering = offerings(:grilled_chicken_veggies)
    vendor = offering.vendor

    inquiry = OfferingInquiry.create!(
      user: @user_one,
      offering: offering,
      serving_size: 10,
      quantity: 2,
      delivery_date: 1.week.from_now,
      notes: "Special dietary requirements"
    )

    perform_enqueued_jobs do
      SendOfferingInquiries.call(@user_one)
    end

    vendor_email = ActionMailer::Base.deliveries.find { |mail| mail.to.include?(vendor.contact_email) }

    assert vendor_email.present?, "Vendor email should be sent"
    assert_equal "New Catering Inquiry from Test User", vendor_email.subject
    assert_match @user_one.email, vendor_email.body.to_s
    assert_match offering.name, vendor_email.body.to_s
    assert_match "10 servings", vendor_email.body.to_s
    assert_match "Special dietary requirements", vendor_email.body.to_s
  end

  def test_sends_user_confirmation_email_with_correct_content
    offering = offerings(:grilled_chicken_veggies)
    vendor = offering.vendor

    inquiry = OfferingInquiry.create!(
      user: @user_one,
      offering: offering,
      serving_size: 10,
      quantity: 2,
      delivery_date: 1.week.from_now
    )

    perform_enqueued_jobs do
      SendOfferingInquiries.call(@user_one)
    end

    user_email = ActionMailer::Base.deliveries.find { |mail| mail.to.include?(@user_one.email) }

    assert user_email.present?, "User confirmation email should be sent"
    assert_equal "Your catering inquiries have been sent", user_email.subject
    assert_match @user_one.email, user_email.body.to_s
    assert_match vendor.business_name, user_email.body.to_s
    assert_match offering.name, user_email.body.to_s
  end

  def test_only_sends_pending_inquiries_not_already_sent
    # Create one pending and one already sent
    offering1 = offerings(:grilled_chicken_veggies)
    offering2 = offerings(:salmon_asparagus)

    pending_inquiry = OfferingInquiry.create!(
      user: @user_one,
      offering: offering1,
      serving_size: 10,
      quantity: 1,
      delivery_date: 1.week.from_now
    )

    sent_inquiry = OfferingInquiry.create!(
      user: @user_one,
      offering: offering2,
      serving_size: 6,
      quantity: 1,
      delivery_date: 1.week.from_now,
      status: "sent",
      sent_at: 1.day.ago
    )

    perform_enqueued_jobs do
      result = SendOfferingInquiries.call(@user_one)

      assert result.success?
      assert_equal 1, result.vendor_count
    end

    # Verify only pending inquiry was marked as sent
    assert_equal "sent", pending_inquiry.reload.status
    assert_equal "sent", sent_inquiry.reload.status # Unchanged

    # Verify emails sent (1 vendor + 1 user confirmation)
    assert_equal 2, ActionMailer::Base.deliveries.size
  end

  def test_does_not_send_cancelled_inquiries
    offering = offerings(:vegan_buddha_bowl)

    cancelled_inquiry = OfferingInquiry.create!(
      user: @user_one,
      offering: offering,
      serving_size: 10,
      quantity: 1,
      delivery_date: 1.week.from_now,
      status: "cancelled"
    )

    result = SendOfferingInquiries.call(@user_one)

    assert_not result.success?
    assert_equal 0, result.vendor_count
    assert_equal "No pending inquiries to send", result.error
  end

  def test_marks_all_inquiries_as_sent_with_timestamp
    offering1 = offerings(:grilled_chicken_veggies)
    offering2 = offerings(:protein_power_bowl)

    inquiry1 = OfferingInquiry.create!(
      user: @user_one,
      offering: offering1,
      serving_size: 10,
      quantity: 1,
      delivery_date: 1.week.from_now
    )

    inquiry2 = OfferingInquiry.create!(
      user: @user_one,
      offering: offering2,
      serving_size: 8,
      quantity: 2,
      delivery_date: 1.week.from_now
    )

    perform_enqueued_jobs do
      SendOfferingInquiries.call(@user_one)
    end

    inquiry1.reload
    inquiry2.reload

    assert_equal "sent", inquiry1.status
    assert_equal "sent", inquiry2.status
    assert_not_nil inquiry1.sent_at
    assert_not_nil inquiry2.sent_at
    assert_in_delta Time.current, inquiry1.sent_at, 2.seconds
    assert_in_delta Time.current, inquiry2.sent_at, 2.seconds
  end
end
