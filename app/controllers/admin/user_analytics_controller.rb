class Admin::UserAnalyticsController < AuthenticatedController
  def index
    @facade = Admin::UserAnalytics::IndexFacade.new(Current.user, params)
  end
end
