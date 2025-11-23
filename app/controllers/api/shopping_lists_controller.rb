class Api::ShoppingListsController < Api::BaseController
  def index
    @shopping_lists = Current.user.shopping_lists.includes(:shopping_list_items)
  end

  def create
    @shopping_list = Current.user.shopping_lists.new(name: params[:name])

    if @shopping_list.save
      render json: @shopping_list, status: :created
    else
      render json: @shopping_list.errors, status: :unprocessable_entity
    end
  end

  def update
    @shopping_list = Current.user.shopping_lists.find(params[:id])

    if @shopping_list.update(shopping_list_params)
      render json: @shopping_list, status: :ok
    else
      render json: { errors: @shopping_list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @shopping_list = Current.user.shopping_lists.find(params[:id])

    if @shopping_list.destroy
      head :no_content
    else
      render json: @shopping_list.errors, status: :unprocessable_entity
    end
  end

  private

  def shopping_list_params
    params.require(:shopping_list).permit(:name, :current)
  end
end
