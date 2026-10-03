class Api::Homes::ShowFacade
  def initialize(user, params)
    @user = user
    @params = params
  end

  def user_id
    @user.id
  end

  def user_name
    @user.first_name
  end

  def recipes
    @user.recipes.visible_to(@user)
      .filtered_by_duration(@params.dig(:filter, :duration))
      .order(created_at: :desc)
      .ransack(@params[:q]).result
      .limit(5)
  end

  def recommendations
    with_visible_recipes = RecipeCategory.joins(:recipes).merge(Recipe.visible_to(@user)).select(:id)

    RecipeCategory.where(id: with_visible_recipes).order(created_at: :desc).limit(4).map do |category|
      {
        id: category.id,
        name: category.name,
        image_url: category.image,
        recipe_count: category.recipes.visible_to(@user).count
      }
    end
  end

  def recipe_categories
    # should eventually be recipes with most recipe associations
    # but for now, just return the first 4 categories alphabetically
    RecipeCategory.order(:name)
      .filtered_by_ids(@params.dig(:filter, :category_ids))
      .ransack(@params[:q]).result
      .limit(4)
  end

  # Saved meal plan covering today; only app builds from before the planner
  # calendar use this
  def current_meal_plan_id
    MealPlanRecipe
      .joins(meal_plan: :user_meal_plans)
      .where(user_meal_plans: { user_id: @user.id })
      .where(date: today)
      .pick(:meal_plan_id)
  end

  def today_recipes
    @user.planned_meals
      .where(date: today, kind: "recipe")
      .includes(recipe: { image_attachment: :blob })
      .ordered
      .map(&:recipe).compact.uniq
  end

  private

  # The app sends the user's local date; the server's may already be tomorrow
  def today
    @today ||= Date.iso8601(@params[:today].to_s)
  rescue Date::Error
    @today = Date.current
  end
end
