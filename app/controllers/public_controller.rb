class PublicController < ApplicationController
  def index
    @facade = Public::IndexFacade.new Current.user, params
  end
end
