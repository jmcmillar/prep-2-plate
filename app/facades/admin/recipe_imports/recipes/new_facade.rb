class Admin::RecipeImports::Recipes::NewFacade < Base::Admin::NewFacade
  DifficultyLevel = Struct.new(:name, :value)
  def active_key 
    :admin_recipes
  end
  
  def import_record
    @import_record ||= RecipeImport.find(@params[:recipe_import_id])
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Recipes", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Import Recipe")
    ]
  end

  def form_url
    [:admin, import_record, :recipes]
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

  # Ingredients are reviewed in the next admin step, so only the recipe
  # details and instructions are built here.
  def recipe
    @recipe ||= RecipeImports::BuildRecipe.call(
      parsed_recipe, recipe_import: import_record, attach_image: false, with_ingredients: false
    )
  end

  def duration
    recipe.duration_minutes
  end

  def serving_size
    recipe.serving_size
  end

  def parsed_recipe
    @parsed_recipe ||= ParseRecipe.new(import_record.url).to_h
  end
end
