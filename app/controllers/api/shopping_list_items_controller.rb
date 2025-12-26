class Api::ShoppingListItemsController < Api::BaseController
  def index
    @shopping_list = Current.user.shopping_lists.find(params[:shopping_list_id])
    @shopping_list_items = @shopping_list.shopping_list_items
      .includes(:ingredient)  # Prevent N+1 queries
      .order(created_at: :desc)
  end

  def create
    @shopping_list = Current.user.shopping_lists.find(params[:shopping_list_id])
    @shopping_list_item = @shopping_list.shopping_list_items.new(shopping_list_item_params)

    if @shopping_list_item.save
      render :show, status: :created
    else
      render json: @shopping_list_item.errors, status: :unprocessable_entity
    end
  end

  def update
    @shopping_list_item = Current.user.shopping_list_items.find(params[:id])

    if @shopping_list_item.update(shopping_list_item_params)
      render :show
    else
      render json: @shopping_list_item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    shopping_list_item = Current.user.shopping_list_items.find(params[:id])

    if shopping_list_item.destroy
      head :no_content
    else
      render json: shopping_list_item.errors, status: :unprocessable_entity
    end
  end

  private

  def shopping_list_item_params
    params.require(:shopping_list_item).permit(:name, :ingredient_id, :packaging_form, :preparation_style)
  end
end
