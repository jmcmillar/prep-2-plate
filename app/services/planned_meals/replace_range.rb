# Replaces everything on a user's planner between two dates with the given
# entries, in order. The app saves a whole visible range at a time, so a
# save is idempotent and the latest one wins.
module PlannedMeals
  class ReplaceRange
    include Service

    MAX_DAYS = 62

    Result = Struct.new(:success?, :planned_meals, :errors)

    def initialize(user:, dates:, entries:)
      @user = user
      @dates = dates
      @entries = Array(entries)
    end

    def call
      return failure("Date range is too long") if @dates.count > MAX_DAYS

      planned_meals = build_planned_meals
      errors = range_errors(planned_meals) + planned_meals.flat_map { |meal| meal.errors.full_messages }
      return failure(*errors.uniq) if errors.any?

      PlannedMeal.transaction do
        @user.planned_meals.where(date: @dates).delete_all
        planned_meals.each(&:save!)
      end

      Result.new(true, planned_meals, [])
    end

    private

    def build_planned_meals
      positions = Hash.new(-1)

      @entries.map do |entry|
        date = parse_date(entry[:date])
        @user.planned_meals.new(
          date: date,
          kind: entry[:kind].presence || "recipe",
          recipe_id: entry[:recipe_id].presence,
          position: positions[date] += 1
        ).tap(&:validate)
      end
    end

    def range_errors(planned_meals)
      return [] if planned_meals.all? { |meal| @dates.cover?(meal.date) }

      [ "Every meal must fall within the dates being saved" ]
    end

    def parse_date(value)
      Date.iso8601(value.to_s)
    rescue Date::Error
      nil
    end

    def failure(*errors)
      Result.new(false, [], errors)
    end
  end
end
