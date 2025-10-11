class Admin::ResourcesController < AuthenticatedController
  def index
    @facade = Admin::Resources::IndexFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::Resources::NewFacade.new(Current.user, params)
  end

  def edit
    @facade = Admin::Resources::EditFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::Resources::NewFacade.new(Current.user, params)
    @facade.resource.assign_attributes(resource_params)
    if @facade.resource.save
      redirect_to admin_resources_url, notice: "Resource was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @facade = Admin::Resources::EditFacade.new(Current.user, params)
    @facade.resource.assign_attributes(resource_params)
    if @facade.resource.update!(resource_params)
      redirect_to admin_resources_url, notice: "Resource was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::Resources::DestroyFacade.new(Current.user, params)
    @facade.resource.destroy
    set_destroy_flash_for(@facade.resource)
  end

  private

  def resource_params
    params.require(:resource).permit(:name, :description, :attachment)
  end
end
