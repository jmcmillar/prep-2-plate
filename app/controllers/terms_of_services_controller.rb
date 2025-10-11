class TermsOfServicesController < ApplicationController
  def show
    @facade = TermsOfServices::ShowFacade.new(Current.user, params)
  end
end
