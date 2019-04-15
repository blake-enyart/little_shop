class Dashboard::ItemDiscountsController < Dashboard::BaseController
  def index
    @item_discounts = ItemDiscount.all
  end

  def new
    @merchant = User.find(params[:merchant_id])
    @discount = @merchant.item_discounts.new
  end

  def create
    @merchant = current_user if current_merchant?
    @discount = @merchant.item_discounts.new(item_discount_params)
    if @discount.save
      flash[:alert] = "Your discount has been saved!"
      redirect_to dashboard_item_discounts_path
    else
      render :new
    end
  end

  private

  def item_discount_params
    params.require(:item_discount).permit(:name, :description, :order_price_threshold, :discount_amount)
  end

end
