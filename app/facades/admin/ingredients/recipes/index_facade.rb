class Admin::Ingredients::Recipes::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_ingredients
  end

  def base_collection
    Base::AdminPolicy::Scope.new(
      @user,
      Recipe.joins(:recipe_ingredients)
            .where(recipe_ingredients: { ingredient_id: ingredient.id })
            .distinct
            .order(:name)
    ).resolve
  end

  def ingredient
    @ingredient ||= Ingredient.find(@params[:ingredient_id])
  end

  def resource_facade_class
    Admin::Ingredients::Recipes::ResourceFacade
  end
end
