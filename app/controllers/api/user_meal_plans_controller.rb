class Api::UserMealPlansController < Api::BaseController
  def create
    result = UserMealPlans::BulkCreate.call(
      user: Current.user,
      meal_plans_params: user_meal_plans_params,
      name: params[:name]
    )

    if result[:success]
      render json: {
        message: "Meal plan saved successfully",
        user_meal_plan: serialize_user_meal_plan(result[:user_meal_plan])
      }, status: :created
    else
      render json: {
        error: result[:error] || "Failed to save meal plan"
      }, status: :unprocessable_entity
    end
  end

  def index
    @user_meal_plans = Current.user.user_meal_plans
      .includes(meal_plan: { meal_plan_recipes: :recipe })
      .order("meal_plan_recipes.date ASC")

    render json: @user_meal_plans.map { |ump| serialize_user_meal_plan(ump) }
  end

  private

  def user_meal_plans_params
    params.require(:user_meal_plans).permit!.to_h
  end

  def serialize_user_meal_plan(user_meal_plan)
    {
      id: user_meal_plan.id,
      meal_plan: {
        id: user_meal_plan.meal_plan.id,
        name: user_meal_plan.meal_plan.name,
        recipes: user_meal_plan.meal_plan.meal_plan_recipes.map do |mpr|
          {
            id: mpr.recipe.id,
            name: mpr.recipe.name,
            date: mpr.date
          }
        end
      },
      created_at: user_meal_plan.created_at,
      updated_at: user_meal_plan.updated_at
    }
  end
end
