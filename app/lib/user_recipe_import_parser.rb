class UserRecipeImportParser
  def initialize(url, user)
    @url = url
    @user = user
  end

  def save
    # Save the recipe_import first, then the user_recipe
    if recipe_import.save
      user_recipe.save
    else
      false
    end
  end

  def user_recipe
    UserRecipe.new(
      user: @user,
      recipe: recipe,
    )
  end

  def recipe
    Recipe.new(
      recipe_import: recipe_import,
      name: parsed_recipe[:name],
      description: parsed_recipe[:description],
    )
  end

  def recipe_import
    @recipe_import ||= RecipeImport.new(
      url: @url,
    )
  end

  def parsed_recipe
    ParseRecipe.new(@url).to_h
  end
end
