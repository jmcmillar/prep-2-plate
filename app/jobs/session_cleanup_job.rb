class SessionCleanupJob < ApplicationJob
  queue_as :default

  def perform
    Session.cleanup_expired
  end
end
