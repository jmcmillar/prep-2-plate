class RecipesController < ApplicationController
  def index
    @facade = Recipes::IndexFacade.new Current.user, params
  end

  def show
    @facade = Recipes::ShowFacade.new Current.user, params
  end
end
