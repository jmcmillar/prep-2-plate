class HttpsUrlValidator < ActiveModel::EachValidator
  # Validates that URLs:
  # 1. Use HTTPS protocol only
  # 2. Are not IP addresses
  # 3. Are not private/local addresses

  def validate_each(record, attribute, value)
    return if value.blank?

    uri = parse_uri(value)

    # If URI parsing failed, the URL is invalid
    if uri.nil?
      record.errors.add(attribute, "is not a valid URL")
      return
    end

    validate_https_protocol(record, attribute, uri)
    validate_not_ip_address(record, attribute, uri)
    validate_not_private_address(record, attribute, uri)
  end

  private

  def parse_uri(value)
    URI.parse(value)
  rescue URI::InvalidURIError
    nil
  end

  def validate_https_protocol(record, attribute, uri)
    if uri.nil?
      record.errors.add(attribute, "must use HTTPS protocol (not http or other protocols)")
      return
    end

    unless uri.scheme == "https"
      record.errors.add(attribute, "must use HTTPS protocol (not http or other protocols)")
    end
  end

  def validate_not_ip_address(record, attribute, uri)
    return if uri.nil? || uri.host.nil?

    # Check for IPv4 addresses (e.g., 192.168.1.1)
    if uri.host =~ /\A\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\z/
      record.errors.add(attribute, "cannot be an IP address. Please use a domain name")
      return
    end

    # Check for IPv6 addresses (e.g., [2001:db8::1] or 2001:db8::1)
    # IPv6 addresses contain colons and hex digits
    stripped_host = uri.host.gsub(/[\[\]]/, "") # Remove brackets if present
    if stripped_host =~ /\A[0-9a-f:]+\z/i && stripped_host.count(":") >= 2
      record.errors.add(attribute, "cannot be an IP address. Please use a domain name")
    end
  end

  def validate_not_private_address(record, attribute, uri)
    return if uri.nil? || uri.host.nil?

    # Block localhost and common private IP ranges
    # localhost, 127.x.x.x (loopback)
    # 10.x.x.x (private class A)
    # 172.16.x.x - 172.31.x.x (private class B)
    # 192.168.x.x (private class C)
    # 169.254.x.x (link-local)
    if uri.host =~ /\A(localhost|127\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|169\.254\.)/i
      record.errors.add(attribute, "cannot use localhost or private IP addresses")
    end
  end
end
