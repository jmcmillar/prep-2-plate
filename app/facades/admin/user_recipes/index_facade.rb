class Admin::UserRecipes::IndexFacade < Base::Admin::IndexFacade
  def menu
    :admin_user_menu
  end

  def active_key
    :admin_user_recipes
  end

  def nav_resource
    parent_resource
  end

  def parent_resource
    @parent_resource ||= User.find(@params[:user_id])
  end
  
  def base_collection
    Base::AdminPolicy::Scope.new(@user, UserRecipe.where(user_id: parent_resource.id)).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Users", [:admin, :users]),
      BreadcrumbComponent::Data.new(parent_resource.email_address, [:admin, parent_resource]),
      BreadcrumbComponent::Data.new("Recipes")
    ]
  end

  def search_data
    SearchFormComponent::Data[
      form_url: [:admin, :user_recipes],
      query: collection.search_collection,
      label: "Search Name, Meal Types, Categories",
      field: :recipe_name_cont
    ]
  end

  def header_actions
    []
  end

  def resource_facade_class
    Admin::UserRecipes::ResourceFacade
  end
end
