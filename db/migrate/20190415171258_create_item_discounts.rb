class CreateItemDiscounts < ActiveRecord::Migration[5.1]
  def change
    create_table :item_discounts do |t|
      t.string :name
      t.text :description
      t.boolean :active, default: false
      t.decimal :order_price_threshold
      t.integer :discount_amount

      t.timestamps
    end
  end
end
