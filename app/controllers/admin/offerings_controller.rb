class Admin::OfferingsController < AuthenticatedController
  def index
    @facade = Admin::Offerings::IndexFacade.new(Current.user, params)
  end

  def show
    @facade = Admin::Offerings::ShowFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::Offerings::NewFacade.new(Current.user, params)
  end

  def edit
    @facade = Admin::Offerings::EditFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::Offerings::NewFacade.new(Current.user, params)

    processed_params = Admin::Offerings::ProcessParams.new(offering_params).call

    @facade.offering.assign_attributes(processed_params)

    if @facade.offering.save
      redirect_to admin_offering_url(@facade.offering), notice: "Offering was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @facade = Admin::Offerings::EditFacade.new(Current.user, params)

    processed_params = Admin::Offerings::ProcessParams.new(offering_params).call

    @facade.offering.assign_attributes(processed_params)

    if @facade.offering.save
      redirect_to admin_offering_url(@facade.offering), notice: "Offering was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::Offerings::DestroyFacade.new(Current.user, params)
    vendor = @facade.offering.vendor
    @facade.offering.destroy
    set_destroy_flash_for(@facade.offering)
    redirect_to admin_vendor_offerings_url(vendor)
  end

  private

  def offering_params
    params.require(:offering).permit(
      :vendor_id, :name, :description, :image, :base_serving_size, :featured,
      meal_type_ids: [],
      offering_ingredients_attributes: [
        :id, :ingredient_id, :ingredient_name, :measurement_unit_id,
        :quantity, :notes, :packaging_form, :preparation_style, :_destroy
      ],
      offering_price_points_attributes: [
        :id, :serving_size, :price, :_destroy
      ]
    )
  end
end
