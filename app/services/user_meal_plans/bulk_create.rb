module UserMealPlans
  class BulkCreate
    include Service

    def initialize(user:, meal_plans_params:, name: nil)
      @user = user
      @meal_plans_params = meal_plans_params
      @name = name
    end

    def call
      return { success: false, error: "No meal plan data provided" } if @meal_plans_params.blank?

      errors = []
      user_meal_plan = nil

      ActiveRecord::Base.transaction do
        # Create a single meal plan for all dates
        meal_plan = MealPlan.new(name: meal_plan_name)

        # Add recipes from all dates to the meal plan
        @meal_plans_params.each do |date, data|
          recipe_ids = data["recipeIds"] || data[:recipeIds] || []
          next if recipe_ids.empty?

          recipe_ids.each do |recipe_id|
            meal_plan.meal_plan_recipes.build(
              recipe_id: recipe_id,
              date: Date.parse(date)
            )
          end
        end

        unless meal_plan.save
          errors << "Failed to save meal plan: #{meal_plan.errors.full_messages.join(', ')}"
          raise ActiveRecord::Rollback
        end

        # Create user_meal_plan association
        user_meal_plan = @user.user_meal_plans.build(meal_plan: meal_plan)

        unless user_meal_plan.save
          errors << "Failed to associate meal plan: #{user_meal_plan.errors.full_messages.join(', ')}"
          raise ActiveRecord::Rollback
        end
      end

      if errors.any?
        { success: false, error: errors.join("; ") }
      else
        { success: true, user_meal_plan: user_meal_plan }
      end
    rescue StandardError => e
      { success: false, error: e.message }
    end

    private

    def meal_plan_name
      return @name if @name.present?
      return "Meal Plan" if @meal_plans_params.blank?

      dates = @meal_plans_params.keys.map { |d| Date.parse(d) }.sort
      return "Meal Plan" if dates.empty?

      start_date = dates.first
      end_date = dates.last

      if start_date == end_date
        "Meal Plan for #{start_date.strftime('%B %d, %Y')}"
      else
        "Meal Plan #{start_date.strftime('%b %d')} - #{end_date.strftime('%b %d, %Y')}"
      end
    end
  end
end
