class Api::ShoppingListItemsController < Api::BaseController
  def index
    @shopping_list = Current.user.shopping_lists.find(params[:shopping_list_id])

    # Allow optional inclusion of archived items
    @shopping_list_items = if ActiveModel::Type::Boolean.new.cast(params[:include_archived])
      @shopping_list.all_shopping_list_items
    else
      @shopping_list.shopping_list_items
    end

    @shopping_list_items = @shopping_list_items
      .includes(:ingredient)  # Prevent N+1 queries
      .order(created_at: :desc)
  end

  def create
    @shopping_list = Current.user.shopping_lists.find(params[:shopping_list_id])
    @shopping_list_item = @shopping_list.shopping_list_items.new(shopping_list_item_params)

    # Apply brand preference if brand is blank
    UserIngredientPreferences::ApplyToItem.call(@shopping_list_item) if @shopping_list_item.brand.blank?

    if @shopping_list_item.save
      # Learn from brand after successful save
      UserIngredientPreferences::Learn.call(@shopping_list_item)

      render :show, status: :created
    else
      render json: @shopping_list_item.errors, status: :unprocessable_entity
    end
  end

  def update
    @shopping_list_item = Current.user.shopping_list_items.find(params[:id])

    if @shopping_list_item.update(shopping_list_item_params)
      # Learn from brand after successful update
      UserIngredientPreferences::Learn.call(@shopping_list_item)

      render :show
    else
      render json: @shopping_list_item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    shopping_list_item = ShoppingListItem.unscoped
      .joins(:shopping_list)
      .where(shopping_lists: { user_id: Current.user.id })
      .find(params[:id])

    if ShoppingListItems::Archive.call(shopping_list_item)
      render json: {
        archived: true,
        archivedAt: shopping_list_item.archived_at,
        name: shopping_list_item.name,
        ingredientId: shopping_list_item.ingredient_id
      }, status: :ok
    else
      render json: { error: "Failed to archive item" }, status: :unprocessable_entity
    end
  end

  private

  def shopping_list_item_params
    params.require(:shopping_list_item).permit(:name, :ingredient_id, :packaging_form, :preparation_style, :brand)
  end
end
