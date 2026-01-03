class ShoppingListItemsController < AuthenticatedController
  layout "application"

  def index
    @facade = ShoppingListItems::IndexFacade.new(Current.user, params)
  end

  def new
    @facade = ShoppingListItems::NewFacade.new(Current.user, params)
  end

  def create
    @facade = ShoppingListItems::NewFacade.new(Current.user, params)
    @facade.shopping_list_item.assign_attributes(shopping_list_item_params)

    # Apply brand preference if brand is blank
    UserIngredientPreferences::ApplyToItem.call(@facade.shopping_list_item) if @facade.shopping_list_item.brand.blank?

    if @facade.shopping_list_item.save
      # Learn from brand after successful save
      UserIngredientPreferences::Learn.call(@facade.shopping_list_item)

      respond_to do |format|
        format.json { render json: { id: @facade.shopping_list_item.id, name: @facade.shopping_list_item.name, display_name: @facade.shopping_list_item.display_name }, status: :created }
        format.html do
          redirect_to shopping_list_items_url(@facade.shopping_list), notice: "Item was successfully created."
        end
      end
    else
      respond_to do |format|
        format.json { render json: { errors: @facade.shopping_list_item.errors.full_messages }, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @facade = ShoppingListItems::EditFacade.new(Current.user, params)
  end

  def update
    @facade = ShoppingListItems::EditFacade.new(Current.user, params)

    if @facade.shopping_list_item.update(shopping_list_item_params)
      # Learn from brand after successful update
      UserIngredientPreferences::Learn.call(@facade.shopping_list_item)

      redirect_to shopping_list_items_url(@facade.shopping_list), notice: "Item was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = ShoppingListItems::DestroyFacade.new(Current.user, params)

    if @facade.archive
      respond_to do |format|
        format.json { render json: { archived: true }, status: :ok }
        format.html do
          redirect_to shopping_list_items_url(@facade.shopping_list),
                      notice: "Item was successfully completed."
        end
      end
    else
      respond_to do |format|
        format.json { render json: { error: "Failed to archive item" }, status: :unprocessable_entity }
        format.html do
          redirect_to shopping_list_items_url(@facade.shopping_list),
                      alert: "Failed to complete item."
        end
      end
    end
  end

  private

  def shopping_list_item_params
    params.require(:shopping_list_item).permit(:name, :ingredient_id, :packaging_form, :preparation_style, :brand)
  end
end
