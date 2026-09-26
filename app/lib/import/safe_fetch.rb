# HTTP GET for user-supplied URLs. Every hop, including each redirect, is
# checked with Import::SafeUrl so a public URL cannot redirect into the
# private network.
class Import::SafeFetch
  TIMEOUT_SECONDS = 10
  MAX_REDIRECTS = 3
  # An honest bot UA: bot-protection services (e.g. Cloudflare) block
  # browser-looking UAs that don't behave like browsers more readily.
  REQUEST_HEADERS = {
    "User-Agent" => "Prep2Plate Recipe Importer/1.0",
    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/*,*/*;q=0.8",
    "Accept-Language" => "en-US,en;q=0.9"
  }.freeze

  class FetchError < StandardError; end

  def self.get(url, **options)
    new(**options).get(url)
  end

  def initialize(http: HTTParty, timeout: TIMEOUT_SECONDS)
    @http = http
    @timeout = timeout
  end

  # Returns the final successful response; raises FetchError otherwise and
  # Import::SafeUrl::UnsafeUrlError for disallowed URLs.
  def get(url, redirects_left = MAX_REDIRECTS)
    Import::SafeUrl.validate!(url)
    response = request(url)
    return follow_redirect(url, response, redirects_left) if response.code.between?(300, 399)
    raise FetchError, "#{url} returned HTTP #{response.code}" unless response.success?

    response
  end

  private

  def follow_redirect(url, response, redirects_left)
    location = response.headers["location"]
    raise FetchError, "Too many redirects" if redirects_left.zero? || location.blank?

    get(URI.join(url, location).to_s, redirects_left - 1)
  end

  def request(url)
    @http.get(url, timeout: @timeout, follow_redirects: false, verify: true, headers: REQUEST_HEADERS)
  rescue HTTParty::Error, Timeout::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError => e
    raise FetchError, "Failed to fetch #{url}: #{e.message}"
  end
end
