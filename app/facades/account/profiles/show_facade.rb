class Account::Profiles::ShowFacade < Base::Authenticated::ShowFacade
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
