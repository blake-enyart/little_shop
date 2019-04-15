class AddMerchantKeyToItemDiscount < ActiveRecord::Migration[5.1]
  def change
    add_reference(:item_discounts, :merchant, foreign_key: {to_table: :users})

  end
end
