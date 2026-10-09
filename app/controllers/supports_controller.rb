class SupportsController < ApplicationController
  def show
    @facade = Supports::ShowFacade.new(Current.user, params)
  end
end
