class Api::MealPlansController < Api::BaseController
  def index
    @meal_plans = Current.user.meal_plans.includes(:meal_plan_recipes)
  end

  def show
    @meal_plan = Current.user.meal_plans
      .includes(meal_plan_recipes: { recipe: { image_attachment: :blob } })
      .find(params[:id])
  end

  def create
    @meal_plan = Current.user.meal_plans.new(meal_plan_params)

    if @meal_plan.save
      render json: @meal_plan, status: :created
    else
      render json: @meal_plan.errors, status: :unprocessable_entity
    end
  end

  def update
    @meal_plan = Current.user.meal_plans.find(params[:id])
    if @meal_plan.update(meal_plan_params)
      render json: @meal_plan, status: :ok
    else
      render json: @meal_plan.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @meal_plan = Current.user.meal_plans.find(params[:id])
    @meal_plan.destroy
    head :no_content
  end

  def meal_plan_params
    params.permit(:name, :description, meal_plan_recipes_attributes: [ :recipe_id, :day_sequence, :date ])
  end
end
