class UserRecipeImports::NewFacade < BaseFacade
  DifficultyLevel = Struct.new(:name, :value)

  def recipe_import
    @recipe_import ||= RecipeImport.find_or_initialize_by(url: @strong_params[:url])
  end

  def form_url
    {
      controller: "user_recipe_imports",
      action: "create"
    }
  end

  # Returns the built recipe. When the page could not be parsed, the recipe
  # carries errors (so the controller does not save it) and the messages are
  # also added to recipe_import, which is what the form displays.
  def recipe
    @recipe ||= valid? ? built_recipe : invalid_recipe
  end

  # Saves the import record and recipe together, then queues categorization
  # for any ingredients the import created.
  def save
    return false unless recipe.errors.empty?

    saved = ActiveRecord::Base.transaction do
      recipe_import.save && recipe.save || raise(ActiveRecord::Rollback)
    end
    RecipeImports::ScheduleIngredientCategorization.call if saved
    saved.present?
  end

  private

  def built_recipe
    RecipeImports::BuildRecipe.call(parsed_recipe, recipe_import: recipe_import).tap do |recipe|
      recipe.build_user_recipe(user: @user)
    end
  end

  def invalid_recipe
    Recipe.new(recipe_import: recipe_import).tap do |recipe|
      validation_errors.each do |message|
        recipe_import.errors.add(:base, message)
        recipe.errors.add(:base, message)
      end
    end
  end

  def valid?
    validation_errors.empty?
  end

  def validation_errors
    @validation_errors ||= parsed_recipe.blank? ? [ fetch_error_message ] : missing_field_errors
  end

  def fetch_error_message
    @fetch_error || "Could not read a recipe from this URL."
  end

  def missing_field_errors
    errors = []
    errors << "Could not parse recipe from URL. Recipe name is required." if parsed_recipe[:name].blank?
    errors << "Could not parse recipe from URL. Recipe must have at least one ingredient." if parsed_recipe[:ingredients].blank?
    errors << "Could not parse recipe from URL. Recipe must have at least one instruction." if parsed_recipe[:instructions].blank?
    errors
  end

  def parsed_recipe
    @parsed_recipe ||= ParseRecipe.new(@strong_params[:url]).to_h
  rescue ParseRecipe::FetchError, Import::SafeUrl::UnsafeUrlError => e
    @fetch_error = "Could not load that page: #{e.message}"
    @parsed_recipe = {}
  end
end
