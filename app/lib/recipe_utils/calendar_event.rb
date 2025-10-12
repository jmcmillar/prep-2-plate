class RecipeUtils::CalendarEvent
  def initialize(recipe, date)
    @recipe = recipe
    @date = date
    @event = Icalendar::Event.new
  end

  def create
    reset
    add_start_time
    add_end_time
    add_summary
    add_description
    @event
  end

  private

  def reset
    @event = Icalendar::Event.new
  end

  def add_start_time
    @event.dtstart = @date
  end

  def add_end_time
    @event.dtend = @date
  end

  def add_summary
    @event.summary = @recipe.recipe_name
  end

  def add_description
    @event.description = Rails.application.routes.url_helpers.url_for(controller: 'recipes', action: 'show', id: @recipe.id, host: Rails.application.config.action_mailer.asset_host)
  end
end
