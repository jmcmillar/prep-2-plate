class OfferingInquiriesController < AuthenticatedController
  layout "application"

  def index
    @facade = OfferingInquiries::IndexFacade.new(Current.user, params)
  end

  def create
    @facade = OfferingInquiries::NewFacade.new(Current.user, params)
    @facade.offering_inquiry.assign_attributes(offering_inquiry_params)

    if @facade.offering_inquiry.save
      redirect_to offering_path(@facade.offering),
        notice: "Offering added to your selections."
    else
      redirect_to offering_path(@facade.offering),
        alert: "Could not add to selections: #{@facade.offering_inquiry.errors.full_messages.join(', ')}"
    end
  end

  def update
    @facade = OfferingInquiries::EditFacade.new(Current.user, params)

    if @facade.offering_inquiry.update(offering_inquiry_params)
      redirect_to offering_inquiries_path,
        notice: "Selection updated."
    else
      redirect_to offering_inquiries_path,
        alert: "Could not update selection: #{@facade.offering_inquiry.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @facade = OfferingInquiries::DestroyFacade.new(Current.user, params)

    if @facade.offering_inquiry.destroy
      redirect_to offering_inquiries_path,
        notice: "Selection removed."
    else
      redirect_to offering_inquiries_path,
        alert: "Could not remove selection."
    end
  end

  def batch_send
    @facade = OfferingInquiries::BatchSendFacade.new(Current.user, params)

    result = SendOfferingInquiries.call(@facade.user)

    if result.success?
      redirect_to offering_inquiries_path,
        notice: "Inquiries sent to #{result.vendor_count} vendor(s)."
    else
      redirect_to offering_inquiries_path,
        alert: result.error
    end
  end

  private

  def offering_inquiry_params
    params.require(:offering_inquiry).permit(
      :offering_id,
      :serving_size,
      :quantity,
      :delivery_date,
      :notes
    )
  end
end
