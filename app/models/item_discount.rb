class ItemDiscount < ApplicationRecord
  validates_presence_of :name,
                        :description,
                        :order_price_threshold,
                        :discount_amount

  belongs_to :user, foreign_key: 'merchant_id'
end
