# Total recipe time in minutes: totalTime when the page gives it, otherwise
# prep time plus cook time. Returns nil when nothing is known.
class RecipeUtils::TotalMinutes
  def self.call(parsed_recipe)
    total = parsed_recipe[:total_time].to_i
    return total if total.positive?

    parts = [ parsed_recipe[:prep_time], parsed_recipe[:cook_time] ].sum(&:to_i)
    parts.positive? ? parts : nil
  end
end
