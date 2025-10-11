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

  def recipe
    @recipe ||= import_record.recipes.new(
      name: parsed_recipe[:name],
    ).tap do |recipe|
      parsed_recipe[:instructions]&.each&.with_index do |ingredient, index|
        recipe.recipe_instructions.build(
          step_number: index + 1,
          instruction: ingredient
        )
      end
    end
  end

  def duration
    parsed_recipe[:total_time]
  end

  def serving_size
    parsed_recipe[:yield]&.to_i
  end

  def parsed_recipe
    @parsed_recipe ||= ParseRecipe.new(import_record.url).to_h
  end
end
