class PublicController < ApplicationController
  def index
    @facade = Public::IndexFacade.new params
  end
end
