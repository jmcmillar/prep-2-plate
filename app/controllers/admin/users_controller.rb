class Admin::UsersController < AuthenticatedController
  def index
    @facade = Admin::Users::IndexFacade.new(Current.user, params)
  end

  def show
    @facade = Admin::Users::ShowFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::Users::NewFacade.new(Current.user)
  end

  def edit
    @facade = Admin::Users::EditFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::Users::NewFacade.new(Current.user, user_params)
    @facade.user.assign_attributes(user_params)

    if @facade.user.save
      redirect_to admin_user_url(@facade.user), notice: "user was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @facade = Admin::Users::EditFacade.new(Current.user, params)
    @facade.user.assign_attributes(user_params)
    if @facade.user.update(user_params)
      redirect_to admin_user_url(@facade.user), notice: "user was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::Users::DestroyFacade.new(Current.user, params)
    @facade.user.destroy
    set_destroy_flash_for(@facade.user)
  end

  private

  def user_params
    params.require(:user).permit(:email, :image)
  end
end
