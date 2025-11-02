class Api::MealPlansController < Api::BaseController
  def create
    @meal_plan = current_user.meal_plans.new(meal_plan_params)

    if @meal_plan.save
      render json: @meal_plan, status: :created
    else
      render json: @meal_plan.errors, status: :unprocessable_entity
    end
  end

  def update
    @meal_plan = UserMealPlan.find(params[:id])
    if @meal_plan.update(meal_plan_params)
      render json: @meal_plan, status: :updated
    else
      render json: @meal_plan.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @meal_plan = UserMealPlan.find(params[:id])

  def meal_plan_params
    params.permit(:name, :description, :meal_plan_recipes_attributes => [:recipe_id, :day_sequence, :date])
  end
end
