class Api::ShoppingLists::ProductsController < Api::BaseController
  # Rate limiting temporarily disabled for initial testing
  # include RateLimitable
  # before_action :check_barcode_rate_limit

  def show
    @shopping_list = Current.user.shopping_lists.find(params[:shopping_list_id])
    barcode = params[:id]

    result = Products::LookupService.call(barcode)

    if result.success?
      @product = result.product
      render :show, status: :ok
    else
      render json: { found: false, message: result.message }, status: :ok
    end
  end

  # private
  #
  # def check_barcode_rate_limit
  #   check_rate_limit(
  #     key: "barcode_lookup:#{Current.user.id}",
  #     limit: 20,
  #     period: 1.minute
  #   )
  # end
end
