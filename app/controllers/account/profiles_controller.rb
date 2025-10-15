class Account::ProfilesController < AuthenticatedController
  def show
    @facade = Account::Profiles::ShowFacade.new(Current.user, params)
  end

  def edit
    @facade = Account::Profiles::EditFacade.new(Current.user, params)
  end

  def update
    @facade = Account::Profiles::ShowFacade.new(Current.user, params)
    @facade.user.assign_attributes(profile_params)
    if @facade.user.update(profile_params)
      redirect_to account_profile_path, notice: "Profiles was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:email, image)
  end
end
