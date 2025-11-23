require "test_helper"

class HttpsUrlValidatorTest < ActiveSupport::TestCase
  class Validatable
    include ActiveModel::Validations
    attr_accessor :url
    validates :url, https_url: true
  end

  def setup
    @model = Validatable.new
  end

  # Valid URLs
  test "accepts valid HTTPS URLs with domain names" do
    valid_urls = [
      "https://example.com",
      "https://www.example.com",
      "https://subdomain.example.com",
      "https://example.com/path/to/recipe",
      "https://example.com/path?query=param",
      "https://example.co.uk",
      "https://example.com:8080/path"
    ]

    valid_urls.each do |url|
      @model.url = url
      assert @model.valid?, "Expected #{url} to be valid, but got errors: #{@model.errors.full_messages}"
    end
  end

  # Invalid: HTTP instead of HTTPS
  test "rejects HTTP URLs" do
    @model.url = "http://example.com"
    assert_not @model.valid?
    assert_includes @model.errors[:url], "must use HTTPS protocol (not http or other protocols)"
  end

  test "rejects URLs without protocol" do
    @model.url = "example.com"
    assert_not @model.valid?
    assert_includes @model.errors[:url], "must use HTTPS protocol (not http or other protocols)"
  end

  test "rejects FTP URLs" do
    @model.url = "ftp://example.com"
    assert_not @model.valid?
    assert_includes @model.errors[:url], "must use HTTPS protocol (not http or other protocols)"
  end

  # Invalid: IP addresses
  test "rejects IPv4 addresses" do
    invalid_ips = [
      "https://192.168.1.1",
      "https://10.0.0.1",
      "https://8.8.8.8",
      "https://172.16.0.1",
      "https://255.255.255.255"
    ]

    invalid_ips.each do |url|
      @model.url = url
      assert_not @model.valid?, "Expected #{url} to be invalid"
      assert_includes @model.errors[:url], "cannot be an IP address. Please use a domain name"
    end
  end

  test "rejects IPv6 addresses" do
    # IPv6 with brackets
    ipv6_with_brackets = [
      "https://[2001:db8::1]",
      "https://[::1]",
      "https://[fe80::1]"
    ]

    ipv6_with_brackets.each do |url|
      @model.url = url
      assert_not @model.valid?, "Expected #{url} to be invalid"
      assert_includes @model.errors[:url], "cannot be an IP address. Please use a domain name"
    end

    # IPv6 without brackets fail to parse and get "is not a valid URL" error
    ipv6_without_brackets = [
      "https://2001:db8::1",
      "https://::1",
      "https://fe80::1"
    ]

    ipv6_without_brackets.each do |url|
      @model.url = url
      assert_not @model.valid?, "Expected #{url} to be invalid"
      assert_includes @model.errors[:url], "is not a valid URL"
    end
  end

  # Invalid: Private/Local addresses
  test "rejects localhost" do
    @model.url = "https://localhost"
    assert_not @model.valid?
    assert_includes @model.errors[:url], "cannot use localhost or private IP addresses"
  end

  test "rejects localhost with port" do
    @model.url = "https://localhost:3000"
    assert_not @model.valid?
    assert_includes @model.errors[:url], "cannot use localhost or private IP addresses"
  end

  test "rejects loopback addresses (127.x.x.x)" do
    @model.url = "https://127.0.0.1"
    assert_not @model.valid?
    assert_includes @model.errors[:url], "cannot use localhost or private IP addresses"
  end

  test "rejects private class A addresses (10.x.x.x)" do
    @model.url = "https://10.0.0.1"
    assert_not @model.valid?
    assert_includes @model.errors[:url], "cannot use localhost or private IP addresses"
  end

  test "rejects private class B addresses (172.16-31.x.x)" do
    @model.url = "https://172.16.0.1"
    assert_not @model.valid?
    assert_includes @model.errors[:url], "cannot use localhost or private IP addresses"

    @model.url = "https://172.31.255.255"
    assert_not @model.valid?
    assert_includes @model.errors[:url], "cannot use localhost or private IP addresses"
  end

  test "rejects private class C addresses (192.168.x.x)" do
    @model.url = "https://192.168.1.1"
    assert_not @model.valid?
    assert_includes @model.errors[:url], "cannot use localhost or private IP addresses"
  end

  test "rejects link-local addresses (169.254.x.x)" do
    @model.url = "https://169.254.1.1"
    assert_not @model.valid?
    assert_includes @model.errors[:url], "cannot use localhost or private IP addresses"
  end

  # Edge cases
  test "allows nil or blank URLs (handled by presence validator)" do
    @model.url = nil
    assert @model.valid?

    @model.url = ""
    assert @model.valid?
  end

  test "handles malformed URLs gracefully" do
    @model.url = "not a url at all"
    assert_not @model.valid?
    assert_includes @model.errors[:url], "is not a valid URL"
  end
end
