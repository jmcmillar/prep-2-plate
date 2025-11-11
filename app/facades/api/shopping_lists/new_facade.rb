class Api::ShoppingLists::NewFacade
  def initialize(user, params)
    @user = user
    @params = params
  end
end
