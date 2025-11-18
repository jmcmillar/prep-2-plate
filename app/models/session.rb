class Session < ApplicationRecord
  belongs_to :user

  # Session configuration
  SESSION_LIFETIME = 2.weeks
  TOKEN_LENGTH = 32

  # Callbacks
  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create

  # Scopes
  scope :active, -> { where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }

  # Validations
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  # Class methods
  def self.find_by_token(token)
    return nil if token.blank?

    session = find_by(token: token)
    return nil unless session&.active?

    session.touch_last_used!
    session
  end

  def self.cleanup_expired
    expired.destroy_all
  end

  # Instance methods
  def active?
    expires_at > Time.current
  end

  def expired?
    !active?
  end

  def touch_last_used!
    update_column(:last_used_at, Time.current)
  end

  def extend_expiration!
    update!(expires_at: SESSION_LIFETIME.from_now)
  end

  def suspicious_activity?(current_ip: nil, current_user_agent: nil)
    # Optional: Detect if IP or user agent has changed
    # You can make this stricter or more lenient based on your needs
    return false if current_ip.blank? && current_user_agent.blank?

    ip_changed = current_ip.present? && ip_address.present? && ip_address != current_ip
    user_agent_changed = current_user_agent.present? && user_agent.present? && user_agent != current_user_agent

    # For now, we'll just track changes but not invalidate sessions
    # You can uncomment the line below to invalidate on IP/UA changes
    # ip_changed || user_agent_changed
    false
  end

  private

  def generate_token
    loop do
      self.token = SecureRandom.urlsafe_base64(TOKEN_LENGTH)
      break unless Session.exists?(token: token)
    end
  end

  def set_expiration
    self.expires_at ||= SESSION_LIFETIME.from_now
  end
end
