class Account::Passwords::EditFacade < Base::Authenticated::EditFacade
  def user
    @user
  end

  def active_key
    :password
  end

  def menu
    :account_setting_menu
  end
end
