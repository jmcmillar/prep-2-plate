class Admin::UsersController < AuthenticatedController
  def index
    @facade = Admin::Users::IndexFacade.new(Current.user, params)
  end

  def show
    @facade = Admin::Users::ShowFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::Users::NewFacade.new(Current.user, params)
  end

  def edit
    @facade = Admin::Users::EditFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::Users::NewFacade.new(Current.user, user_params)
    @facade.resource.assign_attributes(user_params)

    if @facade.resource.save
      redirect_to admin_users_url, notice: "user was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @facade = Admin::Users::EditFacade.new(Current.user, params)
    @facade.resource.assign_attributes(user_params)
    if @facade.resource.update(user_params)
      redirect_to admin_users_url, notice: "user was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :image, :admin)
  end
end
