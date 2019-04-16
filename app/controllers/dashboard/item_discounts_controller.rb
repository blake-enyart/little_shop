class Dashboard::ItemDiscountsController < Dashboard::BaseController
   before_action :set_user, only: [:edit, :update, :destroy, :disable, :enable]

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
    @item_discount.active = false
    if @item_discount.save
      redirect_to dashboard_item_discounts_path
    end
  end

  def enable
    @item_discount.active = true
    if @item_discount.save
      redirect_to dashboard_item_discounts_path
    end
  end

  def edit
    @merchant = current_user if current_merchant?
  end

  def update
    if @item_discount.update(item_discount_params)
      flash[:alert] = "#{@item_discount.name} is now updated!"
      redirect_to dashboard_item_discounts_path
    else
      flash[:danger] = @item_discount.errors.full_messages
      render :edit
    end
  end

  def destroy
    @item_discount.destroy
    flash[:alert] = 'Your discount has been deleted.'
    redirect_to dashboard_item_discounts_path
  end

  private

  def set_user
    @item_discount = ItemDiscount.find(params[:id])
  end

  def item_discount_params
    params.require(:item_discount).permit(:name, :description, :order_price_threshold, :discount_amount)
  end

end
