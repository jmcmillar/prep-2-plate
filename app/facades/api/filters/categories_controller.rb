class Api::Filters::CategoriesController < Api::BaseController
  def index
    @categories = RecipeCategory.all
  end
end
