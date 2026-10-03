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

  def current_meal_plan_id
    today_meal_plan_recipes.first&.meal_plan_id
  end

  def today_recipes
    today_meal_plan_recipes.map(&:recipe).compact.uniq
  end

  private

  def today_meal_plan_recipes
    @today_meal_plan_recipes ||= MealPlanRecipe
      .joins(meal_plan: :user_meal_plans)
      .where(user_meal_plans: { user_id: @user.id })
      .where(date: Date.current)
      .includes(:recipe)
  end
end
