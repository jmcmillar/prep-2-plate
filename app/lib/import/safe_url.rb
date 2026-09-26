require "ipaddr"
require "resolv"

# Guards outbound fetches of user-supplied URLs (recipe pages, recipe images)
# against SSRF: only http(s), and the host must not resolve to a private,
# loopback, or link-local address.
class Import::SafeUrl
  ALLOWED_SCHEMES = %w[http https].freeze

  class UnsafeUrlError < ArgumentError; end

  def self.validate!(url)
    new(url).validate!
  end

  def initialize(url)
    @url = url.to_s
  end

  def validate!
    uri = parse
    raise UnsafeUrlError, "Invalid URL scheme. Only http and https are allowed." unless ALLOWED_SCHEMES.include?(uri.scheme)
    raise UnsafeUrlError, "URL must include a host." if uri.hostname.blank?
    raise UnsafeUrlError, "Access to private IP addresses is not allowed." if private_host?(uri.hostname)

    uri
  end

  private

  def parse
    URI.parse(@url)
  rescue URI::InvalidURIError => e
    raise UnsafeUrlError, "Invalid URL format: #{e.message}"
  end

  def private_host?(host)
    return true if host.casecmp?("localhost")

    resolved_addresses(host).any? { |address| private_address?(address) }
  end

  def resolved_addresses(host)
    return [ IPAddr.new(host) ] if ip_literal?(host)

    Resolv.getaddresses(host).map { |address| IPAddr.new(address) }
  rescue IPAddr::InvalidAddressError
    []
  end

  def ip_literal?(host)
    IPAddr.new(host)
    true
  rescue IPAddr::InvalidAddressError
    false
  end

  def private_address?(address)
    address.private? || address.loopback? || address.link_local? || address.to_s == "0.0.0.0"
  end
end
