class Api::Homes::ShowFacade
  def initialize(user, params)
    @user = user
    @params = params
  end

  def user_id
    @user.id
  end

  def user_name
    @user.first_name
  end

  def recipes
    @user.recipes
      .filtered_by_duration(@params.dig(:filter, :duration))
      .order(created_at: :desc)
      .ransack(@params[:q]).result
      .limit(5)
  end

  def recommendations
    RecipeCategory.includes(:recipes).order(created_at: :desc).where.not(recipes: { id: nil }).limit(4).map do |category|
      {
        id: category.id,
        name: category.name,
        image_url: category.image,
        recipe_count: category.recipes.count
      }
    end
  end

  def recipe_categories
    # should eventually be recipes with most recipe associations
    # but for now, just return the first 4 categories alphabetically
    RecipeCategory.order(:name)
      .filtered_by_ids(@params.dig(:filter, :category_ids))
      .ransack(@params[:q]).result
      .limit(4)
  end
end
