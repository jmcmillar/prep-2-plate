class BaseFacade
  attr_reader :user, :params, :strong_params, :pagy_limit
  def initialize(user, params, **options)
    @user = user
    @params = params
    @strong_params = options.fetch(:strong_params, {})
    @session = options.fetch(:session, {})
  end

  def respond_to_missing?(name, include_private = false)
    resource.respond_to?(name, include_private) || super
  end

  def layout
    Layout.new(menu, active_key, nav_resource, formatter: MenuData::Format.main_menu)
  end

  def menu
    :main_menu
  end

  def active_key
  end

  def nav_resource
  end

  def shopping_list_count
    @user.shopping_list_items.count
  end

  def sign_in_link
    return EmptyComponent.new if @user
    ButtonLinkComponent.new(
      button_link_data: ButtonLinkComponent::Data[
        "Sign In",
        [:new, :session],
        :sign_in,
        :link,
        { class: "self-start" }
      ])
  end

  def sign_out_link
    return EmptyComponent.new unless @user
    ButtonLinkComponent.new(
      button_link_data: ButtonLinkComponent::Data[
        "Sign Out",
        [:session],
        :sign_out,
        :link,
        { class: "self-start", data: { "turbo-method": :delete } }
      ])
  end

  def shopping_list_link
    return EmptyComponent.new unless @user
    IconLinkComponent.new(icon_link: IconLinkComponent::Data[
      [:shopping_lists],
      :clipboard_list,
      "Shopping Lists"
    ])
  end
end
