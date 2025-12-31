require "test_helper"

class VendorTest < ActiveSupport::TestCase
  def setup
    @vendor = vendors(:healthy_meal_co)
  end

  # Validations
  def test_valid_vendor
    assert @vendor.valid?
  end

  def test_business_name_required
    @vendor.business_name = nil
    assert_not @vendor.valid?
    assert_includes @vendor.errors[:business_name], "can't be blank"
  end

  def test_business_name_must_be_unique
    duplicate_vendor = Vendor.new(
      business_name: @vendor.business_name,
      contact_name: "Test",
      contact_email: "test@example.com"
    )
    assert_not duplicate_vendor.valid?
    assert_includes duplicate_vendor.errors[:business_name], "has already been taken"
  end

  def test_contact_name_required
    @vendor.contact_name = nil
    assert_not @vendor.valid?
    assert_includes @vendor.errors[:contact_name], "can't be blank"
  end

  def test_contact_email_required
    @vendor.contact_email = nil
    assert_not @vendor.valid?
    assert_includes @vendor.errors[:contact_email], "can't be blank"
  end

  def test_contact_email_format_validation
    invalid_emails = ["invalid", "test@", "@example.com", "test@@example.com"]
    invalid_emails.each do |invalid_email|
      @vendor.contact_email = invalid_email
      assert_not @vendor.valid?, "#{invalid_email} should be invalid"
      assert_includes @vendor.errors[:contact_email], "is invalid"
    end
  end

  def test_valid_email_formats
    valid_emails = ["test@example.com", "user.name@example.co.uk", "test+tag@example.com"]
    valid_emails.each do |valid_email|
      @vendor.contact_email = valid_email
      assert @vendor.valid?, "#{valid_email} should be valid"
    end
  end

  def test_status_validation
    @vendor.status = "invalid_status"
    assert_not @vendor.valid?
    assert_includes @vendor.errors[:status], "is not included in the list"
  end

  def test_valid_status_values
    %w[active inactive].each do |status|
      @vendor.status = status
      assert @vendor.valid?, "#{status} should be a valid status"
    end
  end

  # Associations
  def test_has_many_offerings
    assert_respond_to @vendor, :offerings
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @vendor.offerings
  end

  def test_destroying_vendor_destroys_offerings
    offering = @vendor.offerings.create!(
      name: "Test Offering",
      base_serving_size: 2
    )
    offering_count = @vendor.offerings.count
    assert_difference "Offering.count", -offering_count do
      @vendor.destroy
    end
  end

  def test_has_one_attached_logo
    assert_respond_to @vendor, :logo
  end

  # Scopes
  def test_active_scope
    active_vendors = Vendor.active
    assert_includes active_vendors, vendors(:healthy_meal_co)
    assert_not_includes active_vendors, vendors(:inactive_vendor)
  end

  def test_inactive_scope
    inactive_vendors = Vendor.inactive
    assert_includes inactive_vendors, vendors(:inactive_vendor)
    assert_not_includes inactive_vendors, vendors(:healthy_meal_co)
  end

  # Instance Methods
  def test_activate_changes_status_to_active
    inactive_vendor = vendors(:inactive_vendor)
    inactive_vendor.activate!
    assert_equal "active", inactive_vendor.status
  end

  def test_active_returns_true_for_active_vendor
    assert @vendor.active?
  end

  def test_active_returns_false_for_inactive_vendor
    inactive_vendor = vendors(:inactive_vendor)
    assert_not inactive_vendor.active?
  end

  # Ransackable attributes
  def test_ransackable_attributes
    assert_includes Vendor.ransackable_attributes, "business_name"
    assert_includes Vendor.ransackable_attributes, "contact_name"
    assert_includes Vendor.ransackable_attributes, "status"
  end

  def test_ransackable_associations
    assert_includes Vendor.ransackable_associations, "offerings"
  end
end
