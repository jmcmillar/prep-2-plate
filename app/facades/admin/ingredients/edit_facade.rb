class Admin::Ingredients::EditFacade < Base::Admin::EditFacade
  def ingredient
    @ingredient ||= Ingredient.find(@params[:id])
  end

  def active_key
    :admin_ingredients
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Ingredients", [:admin, :ingredients]),
      BreadcrumbComponent::Data.new("Edit")
    ]
  end

  def form_url
    [:admin, ingredient]
  end

  def cancel_path
    [:admin, :ingredients]
  end
end
