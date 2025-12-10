class Api::RecipeCategories::IndexFacade
  include ActionView::Helpers::TranslationHelper
  include ApplicationHelper
  include ActionView::Helpers::AssetUrlHelper

  def initialize(user, params, request = nil)
    @user = user
    @params = params
    @request = request
  end

  def recipe_categories
    # Preload favorited recipe IDs to avoid N+1 queries
    preload_favorited_recipe_ids

    categories.includes(:recipes).map { |category|
      {
        id: category.id,
        name: category.name,
        recipes: category_recipes(category)
      }
    }.prepend(my_recipe_category)
  end

  def recipe_favorite(recipe)
    @favorited_recipe_ids.include?(recipe.id)
  end

  private

  def my_recipe_category
    {
      id: 0,
      name: "My Recipes",
      recipes: Recipe.includes(:user_recipe).where(user_recipe: { user_id: @user.id }).filtered_by_duration((@params.dig(:filter, :duration) || nil))
        .ransack(@params[:q]).result.limit(10)
    }
  end

  def categories
    @categories ||= RecipeCategory.joins(:recipes).filtered_by_ids(@params.dig(:filter, :category_ids))
      .distinct
  end

  def category_recipes(category)
    category.recipes
      .filtered_by_duration((@params.dig(:filter, :duration) || nil))
      .ransack(@params[:q]).result.limit(10)
  end

  def preload_favorited_recipe_ids
    return if @favorited_recipe_ids

    # Collect all recipe IDs that will be displayed
    all_recipe_ids = categories.flat_map { |category| category_recipes(category).pluck(:id) }
    all_recipe_ids += my_recipe_category[:recipes].pluck(:id)

    # Load favorites in one query
    @favorited_recipe_ids = RecipeFavorite
      .where(user: @user, recipe_id: all_recipe_ids)
      .pluck(:recipe_id)
      .to_set
  end

  def default_image
    Rails.application.routes.url_helpers.image_url("no-recipe-image.png", host: @request.host_with_port)
  end

  def attachment_url(attachment)
    Rails.application.routes.url_helpers.rails_blob_url(
      attachment, host: @request.host_with_port
    )
  end
end
