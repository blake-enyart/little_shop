class Cart
  attr_reader :contents

  def initialize(initial_contents)
    @contents = initial_contents || Hash.new(0)
    @contents.default = 0
  end

  def total_item_count
    @contents.values.sum
  end

  def add_item(item_id)
    @contents[item_id.to_s] += 1
  end

  def remove_item(item_id)
    @contents[item_id.to_s] -= 1
    @contents.delete(item_id.to_s) if count_of(item_id) == 0
  end

  def count_of(item_id)
    @contents[item_id.to_s]
  end

  def items
    @items ||= load_items
  end

  def load_items
    @contents.map do |item_id, quantity|
      item = Item.find(item_id)
      [item, quantity]
    end.to_h
  end

  def total
    items.sum do |item, quantity|
      if item.user.item_discounts.count == 0
        item.price * quantity
      else
        subtotal(item)
      end
    end
  end

  def subtotal(item)
    merchant_discounts = find_all_discounts(@cart)[item.user]
    if merchant_discounts
      determine_discount_use(item, merchant_discounts)
    else #no discounts available from merchant
      count_of(item.id) * item.price
    end
  end

  def find_all_discounts(cart)
    items().keys.inject({}) do |hash, item|
      if item.user.item_discounts.count > 0
        hash[item.user] = item.user.item_discounts
      end
      hash
    end
  end

  def determine_discount_use(item, merchant_discounts)
    full_price = count_of(item.id) * item.price
    selected_discounts = merchant_discounts.select do |discount|
      discount.order_price_threshold <= full_price && discount.active
    end
    if selected_discounts.count > 0
      choose_best_discount(item, full_price, selected_discounts)
    else
      full_price
    end
  end

  def choose_best_discount(item, full_price, selected_discounts)
    discount = selected_discounts.max_by{ |discount| discount.discount_amount }
    full_price - discount.discount_amount
  end
end
