require 'factory_bot_rails'

include FactoryBot::Syntax::Methods

OrderItem.destroy_all
Order.destroy_all
Item.destroy_all
User.destroy_all

admin = create(:admin)
user = create(:user)
merchant_1 = create(:merchant)

merchant_2, merchant_3, merchant_4 = create_list(:merchant, 3)

inactive_merchant_1 = create(:inactive_merchant)
inactive_user_1 = create(:inactive_user)

item_1 = create(:item, user: merchant_1)
item_2 = create(:item, user: merchant_2)
item_3 = create(:item, user: merchant_3)
item_4 = create(:item, user: merchant_4)
create_list(:item, 10, user: merchant_1)

inactive_item_1 = create(:inactive_item, user: merchant_1)
inactive_item_2 = create(:inactive_item, user: inactive_merchant_1)

u1 = create(:user, state: "CO", city: "Fairfield")
u3 = create(:user, state: "IA", city: "Fairfield")
u2 = create(:user, state: "OK", city: "OKC")
u4 = create(:user, state: "IA", city: "Des Moines")
u5 = create(:user, state: "IA", city: "Des Moines")
u6 = create(:user, state: "IA", city: "Des Moines")
m1, m2, m3, m4, m5, m6, m7 = create_list(:merchant, 7)
i1 = create(:item, merchant_id: m1.id)
i2 = create(:item, merchant_id: m2.id)
i3 = create(:item, merchant_id: m3.id)
i4 = create(:item, merchant_id: m4.id)
i5 = create(:item, merchant_id: m5.id)
i6 = create(:item, merchant_id: m6.id)
i7 = create(:item, merchant_id: m7.id)
o1 = create(:shipped_order, user: u1)
o2 = create(:shipped_order, user: u2)
o3 = create(:shipped_order, user: u3)
o4 = create(:shipped_order, user: u1)
o5 = create(:cancelled_order, user: u5)
o6 = create(:shipped_order, user: u6)
o7 = create(:shipped_order, user: u6)
oi1 = create(:fulfilled_order_item, item: i1, order: o1, created_at: 5.minutes.ago)
oi2 = create(:fulfilled_order_item, item: i2, order: o2, created_at: 53.5.hours.ago)
oi3 = create(:fulfilled_order_item, item: i3, order: o3, created_at: 6.days.ago)
oi4 = create(:order_item, item: i4, order: o4, created_at: 4.days.ago)
oi5 = create(:order_item, item: i5, order: o5, created_at: 5.days.ago)
oi6 = create(:fulfilled_order_item, item: i6, order: o6, created_at: 3.days.ago)
oi7 = create(:fulfilled_order_item, item: i7, order: o7, created_at: 2.hours.ago)
# Random.new_seed
# rng = Random.new

# order = create(:shipped_order, user: user)
# create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1, created_at: (rng.rand(3)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
# create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)
# create(:fulfilled_order_item, order: order, item: item_3, price: 3, quantity: 1, created_at: (rng.rand(5)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
# create(:fulfilled_order_item, order: order, item: item_4, price: 4, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)

# # pending order
# order = create(:order, user: user)
# create(:order_item, order: order, item: item_1, price: 1, quantity: 1)
# create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).days.ago, updated_at: rng.rand(23).hours.ago)

# order = create(:cancelled_order, user: user)
# create(:order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)
# create(:order_item, order: order, item: item_3, price: 3, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)

# order = create(:shipped_order, user: user)
# create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1, created_at: (rng.rand(4)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
# create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)





puts 'seed data finished'
puts "Users created: #{User.count.to_i}"
puts "Orders created: #{Order.count.to_i}"
puts "Items created: #{Item.count.to_i}"
puts "OrderItems created: #{OrderItem.count.to_i}"
