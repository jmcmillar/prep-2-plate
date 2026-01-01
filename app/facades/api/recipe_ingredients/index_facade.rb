class Api::RecipeIngredients::IndexFacade
  def initialize(user, params)
    @user = user
    @params = params
  end

  def current_shopping_list_id
    @current_shopping_list_id ||= @user.shopping_lists.where(current: true)&.first&.id || nil
  end

  def recipe_ingredients
    @recipe_ingredients ||= IngredientFullNameDecorator.decorate_collection(
      RecipeIngredient
        .includes(:recipe, ingredient: :ingredient_category)
        .where(recipe: { id: @params[:recipe_ids] })
        .order("ingredients.name")
    )
  end

  def grouped_ingredients
    @grouped_ingredients ||= recipe_ingredients.group_by do |recipe_ingredient|
      recipe_ingredient.ingredient.ingredient_category || uncategorized_category
    end.sort_by { |category, _| category.name }
  end

  private

  def uncategorized_category
    @uncategorized_category ||= IngredientCategory.new(id: nil, name: "Uncategorized")
  end
end
