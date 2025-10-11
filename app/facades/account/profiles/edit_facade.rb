class Account::Profiles::EditFacade < Base::Authenticated::EditFacade
  def user
    @user
  end

  def active_key
    :account_settings
  end

  def menu
    :account_setting_menu
  end
end
