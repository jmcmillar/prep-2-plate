class Public::IndexFacade < BaseFacade
   def initialize(user, params, **options)
    @user = user
    @params = params
    @strong_params = options.fetch(:strong_params, {})
    @session = options.fetch(:session, {})
  end
  def recipes
    @recipes ||= Recipe
      .order(:name)
      .featured
      .with_attached_image
      .includes(:meal_types, :recipe_categories, recipe_ingredients: [ :measurement_unit, :ingredient ])
      .to_a
      .map { |recipe| Recipes::ResourceFacade.new(recipe) }
  end

  def meal_plans
    MealPlan.order(:name).featured
  end
end
