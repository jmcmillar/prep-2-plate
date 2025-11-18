namespace :sessions do
  desc "Clean up expired sessions"
  task cleanup: :environment do
    count = Session.cleanup_expired
    puts "Cleaned up #{count} expired sessions"
  end

  desc "Show session statistics"
  task stats: :environment do
    total = Session.count
    active = Session.active.count
    expired = Session.expired.count

    puts "Session Statistics:"
    puts "  Total sessions: #{total}"
    puts "  Active sessions: #{active}"
    puts "  Expired sessions: #{expired}"
  end
end
