class OfferingInquiries::DestroyFacade < BaseFacade
  def initialize(user, params)
    super
    raise Pundit::NotAuthorizedError unless authorized?
  end

  def offering_inquiry
    @offering_inquiry ||= user.offering_inquiries.pending.find(params[:id])
  end

  private

  def authorized?
    Base::AuthenticatedPolicy.new(user, offering_inquiry).destroy?
  end
end
