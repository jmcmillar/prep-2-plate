require "open-uri"
class ParseRecipe
  SSRF_PROTECTED_SCHEMES = %w[http https].freeze
  TIMEOUT_SECONDS = 10

  def initialize(url)
    validate_url!(url)
    @url = fetch_url(url)
  end

  def to_h
    Parser.parse(@url).to_h
  end

  private

  def validate_url!(url)
    uri = URI.parse(url)

    unless SSRF_PROTECTED_SCHEMES.include?(uri.scheme)
      raise ArgumentError, "Invalid URL scheme. Only http and https are allowed."
    end

    # Prevent access to private IP ranges (SSRF protection)
    if uri.host =~ /^(localhost|127\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|169\.254\.)/i
      raise ArgumentError, "Access to private IP addresses is not allowed."
    end
  rescue URI::InvalidURIError => e
    raise ArgumentError, "Invalid URL format: #{e.message}"
  end

  def fetch_url(url)
    HTTParty.get(url,
      timeout: TIMEOUT_SECONDS,
      follow_redirects: true,
      max_redirects: 3,
      verify: true,  # Verify SSL certificates
      headers: {
        "User-Agent" => "Prep2Plate Recipe Importer/1.0"
      }
    )
  rescue HTTParty::Error, Timeout::Error, SocketError => e
    raise StandardError, "Failed to fetch recipe: #{e.message}"
  end
end
