class AboutsController < ApplicationController
  def show
    @facade = Abouts::ShowFacade.new(Current.user, params)
  end
end
