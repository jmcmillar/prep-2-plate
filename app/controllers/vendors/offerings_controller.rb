class Vendors::OfferingsController < AuthenticatedController
  layout "application"

  def index
    @facade = Vendors::Offerings::IndexFacade.new(Current.user, params)
  end
end
