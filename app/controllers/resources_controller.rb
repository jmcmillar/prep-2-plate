class ResourcesController < ApplicationController
  def index
    @facade = Resources::IndexFacade.new Current.user, params
  end
end
