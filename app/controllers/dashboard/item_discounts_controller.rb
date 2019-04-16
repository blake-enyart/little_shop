class Dashboard::ItemDiscountsController < Dashboard::BaseController
  def index
    @item_discounts = ItemDiscount.all
  end

  def new
    @merchant = User.find(params[:merchant_id])
    @item_discount = @merchant.item_discounts.new
  end

  def create
    @merchant = current_user if current_merchant?
    @item_discount = @merchant.item_discounts.new(item_discount_params)
    if @item_discount.save
      flash[:alert] = "Your discount has been saved!"
      redirect_to dashboard_item_discounts_path
    else
      render :new
    end
  end

  def disable
    @item_discount = ItemDiscount.find(params[:id])
    @item_discount.active = false
    if @item_discount.save
      redirect_to dashboard_item_discounts_path
    end
  end

  def enable
    @item_discount = ItemDiscount.find(params[:id])
    @item_discount.active = true
    if @item_discount.save
      redirect_to dashboard_item_discounts_path
    end
  end

  def edit
    @merchant = current_user if current_merchant?
    @item_discount = ItemDiscount.find(params[:id])
  end

  def update
    @item_discount = ItemDiscount.find(params[:id])
    if @item_discount.update(item_discount_params)
      flash[:alert] = "#{@item_discount.name} is now updated!"
      redirect_to dashboard_item_discounts_path
    else
      flash[:danger] = @item_discount.errors.full_messages
      render :edit
    end
  end

  private

  def item_discount_params
    params.require(:item_discount).permit(:name, :description, :order_price_threshold, :discount_amount)
  end

end
