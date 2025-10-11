class Admin::Recipes::EditFacade < Base::Admin::EditFacade
  DifficultyLevel = Struct.new(:name, :value)
  def recipe
    @recipe ||= Recipe.find(@params[:id])
  end

  def active_key
    :admin_recipes
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Recipes", [:admin, :recipes]),
      BreadcrumbComponent::Data.new(recipe.name, [:admin, recipe]),
      BreadcrumbComponent::Data.new("Edit")
    ]
  end

  def form_url
    [:admin, recipe]
  end

  def difficulty_levels
    Recipe.difficulty_levels.map do |level|
      DifficultyLevel[*level]
    end
  end

  def categories
    @categories ||= RecipeCategory.all.order(:name)
  end

  def meal_types
    @meal_types ||= MealType.all.order(:name)
  end
end
