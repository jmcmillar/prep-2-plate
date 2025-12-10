class Admin::UserRecipes::EditFacade < Base::Admin::EditFacade
  DifficultyLevel = Struct.new(:name, :value)
  def user_recipe
    @recipe ||= UserRecipe.find(@params[:id])
  end

  def parent_resource
    user_recipe.user
  end

   def menu
    :admin_user_menu
  end

  def active_key
    :admin_user_recipes
  end

  def nav_resource
    parent_resource
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Users", [:admin, :users]),
      BreadcrumbComponent::Data.new(parent_resource.email, [:admin, parent_resource]),
      BreadcrumbComponent::Data.new("Recipes", [:admin, parent_resource,:user_recipes]),
      BreadcrumbComponent::Data.new(user_recipe.name, [:admin, user_recipe]),
      BreadcrumbComponent::Data.new("Edit")
    ]
  end

  def form_url
    [:admin, user_recipe]
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
