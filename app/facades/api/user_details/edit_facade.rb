class Api::UserDetails::EditFacade
  attr_reader :user
  def initialize(user, params)
    @user = user
    @params = params
  end
end
