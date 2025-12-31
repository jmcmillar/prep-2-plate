class Admin::VendorsController < AuthenticatedController
  def index
    @facade = Admin::Vendors::IndexFacade.new(Current.user, params)
  end

  def show
    @facade = Admin::Vendors::ShowFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::Vendors::NewFacade.new(Current.user, params)
  end

  def edit
    @facade = Admin::Vendors::EditFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::Vendors::NewFacade.new(Current.user, params)
    @facade.vendor.assign_attributes(vendor_params)
    if @facade.vendor.save
      redirect_to admin_vendor_url(@facade.vendor), notice: "Vendor was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @facade = Admin::Vendors::EditFacade.new(Current.user, params)
    if @facade.vendor.update(vendor_params)
      redirect_to admin_vendor_url(@facade.vendor), notice: "Vendor was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::Vendors::DestroyFacade.new(Current.user, params)
    @facade.vendor.destroy
    set_destroy_flash_for(@facade.vendor)
    redirect_to admin_vendors_url
  end

  private

  def vendor_params
    params.require(:vendor).permit(
      :business_name, :contact_name, :contact_email, :description,
      :phone_number, :website_url, :street_address, :city, :state,
      :zip_code, :status, :logo
    )
  end
end
