class ShoppingListItems::NewFacade < BaseFacade
  def shopping_list_item
    @shopping_list_item ||= shopping_list.shopping_list_items.new
  end

  def shopping_list
    @user.shopping_lists.find_by(id: @params[:shopping_list_id], user_id: @user.id)
  end

  def form_url
    {
      controller: "shopping_list_items",
      shopping_list_id: shopping_list.id,
      action: "create"
    }
  end

  def cancel_path
    {
      controller: "shopping_list_items",
      shopping_list_id: shopping_list.id,
      action: "index"
    }
  end

  def suggested_brand(ingredient_id, packaging_form, preparation_style)
    return nil unless ingredient_id.present? && @user.present?

    preference = UserIngredientPreference.find_best_match(
      @user.id,
      ingredient_id,
      packaging_form,
      preparation_style
    )

    preference&.preferred_brand
  end
end
