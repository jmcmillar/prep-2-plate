class Public::IndexFacade < BaseFacade
   def initialize(user, params, **options)
    @user = user
    @params = params
    @strong_params = options.fetch(:strong_params, {})
    @session = options.fetch(:session, {})
  end
  def recipes
    []
    Recipe.order(:name).featured.map do |recipe|
      Recipes::ResourceFacade.new(recipe)
    end
  end

  def meal_plans
    MealPlan.order(:name).featured
  end
end
