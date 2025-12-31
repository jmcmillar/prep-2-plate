class OfferingsController < PublicController
  def index
    @facade = Offerings::IndexFacade.new(Current.user, params)
  end

  def show
    @facade = Offerings::ShowFacade.new(Current.user, params)
  end
end
