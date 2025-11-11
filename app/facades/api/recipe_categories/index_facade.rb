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
    categories.includes(:recipes).map { |category| 
      { 
        id: category.id,
        name: category.name,
        recipes: category_recipes(category)
      }
    }
  end

  private

  def categories
    @categories ||= RecipeCategory.joins(:recipes).filtered_by_ids(@params.dig(:filter, :category_ids))
      .distinct
  end

  def category_recipes(category)
    category.recipes
      .filtered_by_duration((@params.dig(:filter, :duration) || nil))
      .ransack(@params[:q]).result
  end

  def recipe_favorite(recipe)
    RecipeFavorite.find_by(user: @user, recipe: recipe).present?
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
