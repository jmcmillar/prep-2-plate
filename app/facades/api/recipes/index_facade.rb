class Api::Recipes::IndexFacade
  def initialize(user, params)
    @user = user
    @params = params
  end

  def recipes
    (@params[:category_id] ? recipes_by_category : base_recipes).then do |recipes|
      recipes.map { |recipe| set_recipe(recipe) }
    end
  end

  def all_recipes
    @recipes ||= Recipe.order(:name)
  end

  def recipes_by_category
    base_recipes.where(category_id: @params[:category_id])
  end

  def set_recipe(recipe)
    {
      id: recipe.id,
      name: recipe.name,
      instructions: recipe.instructions,
      imageUrl: recipe.image.attachected? ? recipe.image : nil,
      ingredients: recipe.ingredients.map { |ingredient| set_ingredient(ingredient) }
    }
  end

  def set_ingredient(ingredient)
    {
      id: ingredient.id,
      name: ingredient.name
    }
  end
end
