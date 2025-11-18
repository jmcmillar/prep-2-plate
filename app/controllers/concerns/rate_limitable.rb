module RateLimitable
  extend ActiveSupport::Concern

  class RateLimitExceeded < StandardError; end

  included do
    rescue_from RateLimitExceeded, with: :render_rate_limit_error
  end

  private

  def check_rate_limit(key:, limit:, period:)
    cache_key = "rate_limit:#{key}:#{request.remote_ip}"
    attempts = Rails.cache.read(cache_key) || 0

    if attempts >= limit
      Rails.logger.warn("Rate limit exceeded for #{key} from IP: #{request.remote_ip}")
      raise RateLimitExceeded
    end

    Rails.cache.write(cache_key, attempts + 1, expires_in: period)
  end

  def render_rate_limit_error
    if request.format.json? || request.path.start_with?('/api')
      render json: {
        status: 429,
        message: 'Too many requests. Please try again later.'
      }, status: :too_many_requests
    else
      flash[:alert] = 'Too many requests. Please try again later.'
      redirect_to root_path
    end
  end
end
