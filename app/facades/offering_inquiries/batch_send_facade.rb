class OfferingInquiries::BatchSendFacade < BaseFacade
  def initialize(user, params)
    super
    raise Pundit::NotAuthorizedError unless authorized?
  end

  private

  def authorized?
    Base::AuthenticatedPolicy.new(user, nil).create?
  end
end
