class Admin::RecipeImports::Ingredients::NewFacade < Base::Admin::IndexFacade
  def recipe
    @recipe ||= Recipe.find(@params[:recipe_id])
  end

  def build_ingredient_list
    BuildRecipeIngredients.call(
      recipe.id,
      @params[:recipe_ingredients_attributes]
    )
  end

  def import_url
    recipe.recipe_import.url
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Recipes", [:admin, :recipes]),
      BreadcrumbComponent::Data.new(recipe.name, [:admin, recipe]),
      BreadcrumbComponent::Data.new("Import Ingredients")
    ]
  end

  def form_url
    [:admin, recipe, :import_ingredients]
  end

  def ingredients
    @ingredients ||= parsed_recipe[:ingredients].map do |ingredient|
      ParseIngredient.new(ingredient).to_h
    end
  end

  def parsed_recipe
    @parsed_recipe ||= ParseRecipe.new(import_url).to_h
  end
end
