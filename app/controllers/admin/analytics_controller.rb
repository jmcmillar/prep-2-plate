class Admin::AnalyticsController < AuthenticatedController
  def shopping_lists
    @facade = Admin::Analytics::ShoppingListsFacade.new(Current.user, params)
  end

  def user_preferences
    @facade = Admin::Analytics::UserPreferencesFacade.new(Current.user, params)
  end
end
