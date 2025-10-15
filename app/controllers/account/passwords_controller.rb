class Account::PasswordsController < AuthenticatedController
  def edit
    @facade = Account::Passwords::EditFacade.new(Current.user, params)
  end

  def update
    @facade = Account::Passwords::EditFacade.new(Current.user, params)
    if @facade.user.update_with_password(password_params)
      bypass_sign_in @facade.user
      redirect_to account_password_path, notice: "Password was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end
end
