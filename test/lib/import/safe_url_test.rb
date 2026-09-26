require "test_helper"

class Import::SafeUrlTest < ActiveSupport::TestCase
  def test_allows_public_http_urls
    assert_equal "93.184.216.34", Import::SafeUrl.validate!("https://93.184.216.34/recipe").host
  end

  def test_rejects_private_loopback_and_link_local_addresses
    %w[
      http://127.0.0.1/ http://10.0.0.5/ http://192.168.1.1/ http://172.16.0.1/
      http://169.254.169.254/latest/meta-data http://[::1]/ http://localhost:3000/ http://0.0.0.0/
    ].each do |url|
      assert_raises(Import::SafeUrl::UnsafeUrlError, url) { Import::SafeUrl.validate!(url) }
    end
  end

  def test_rejects_hostnames_resolving_to_private_addresses
    Resolv.stub(:getaddresses, [ "10.1.2.3" ]) do
      assert_raises(Import::SafeUrl::UnsafeUrlError) { Import::SafeUrl.validate!("https://internal.example.com/") }
    end
  end

  def test_rejects_other_schemes_and_malformed_urls
    assert_raises(Import::SafeUrl::UnsafeUrlError) { Import::SafeUrl.validate!("file:///etc/passwd") }
    assert_raises(Import::SafeUrl::UnsafeUrlError) { Import::SafeUrl.validate!("http://exa mple.com") }
  end

  def test_unsafe_url_error_is_an_argument_error
    assert Import::SafeUrl::UnsafeUrlError < ArgumentError
  end
end
