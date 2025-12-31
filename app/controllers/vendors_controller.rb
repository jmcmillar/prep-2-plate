class VendorsController < PublicController
  def index
    @facade = Vendors::IndexFacade.new(Current.user, params)
  end

  def show
    @facade = Vendors::ShowFacade.new(Current.user, params)
  end
end
