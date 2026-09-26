require "test_helper"

class Import::SafeFetchTest < ActiveSupport::TestCase
  Response = Struct.new(:code, :headers, :body) do
    def success?
      code.between?(200, 299)
    end
  end

  class FakeHttp
    attr_reader :requested

    def initialize(responses)
      @responses = responses
      @requested = []
    end

    def get(url, **)
      @requested << url
      @responses.fetch(url)
    end
  end

  def test_returns_successful_response
    http = FakeHttp.new("https://93.184.216.34/r" => Response.new(200, {}, "<html></html>"))

    assert_equal "<html></html>", Import::SafeFetch.get("https://93.184.216.34/r", http: http).body
  end

  def test_follows_redirects_to_public_hosts
    http = FakeHttp.new(
      "https://93.184.216.34/r" => Response.new(301, { "location" => "/final" }, ""),
      "https://93.184.216.34/final" => Response.new(200, {}, "ok")
    )

    assert_equal "ok", Import::SafeFetch.get("https://93.184.216.34/r", http: http).body
  end

  def test_refuses_redirect_into_private_network
    http = FakeHttp.new("https://93.184.216.34/r" => Response.new(302, { "location" => "http://169.254.169.254/" }, ""))

    assert_raises(Import::SafeUrl::UnsafeUrlError) { Import::SafeFetch.get("https://93.184.216.34/r", http: http) }
    assert_equal [ "https://93.184.216.34/r" ], http.requested
  end

  def test_raises_fetch_error_on_error_status
    http = FakeHttp.new("https://93.184.216.34/r" => Response.new(403, {}, "blocked"))

    error = assert_raises(Import::SafeFetch::FetchError) { Import::SafeFetch.get("https://93.184.216.34/r", http: http) }
    assert_match "403", error.message
  end
end
