FactoryBot.define do
  factory :item_discount do
    association :user, factory: :merchant
    sequence(:name) { |n| "Discount Name #{n}" }
    sequence(:description) { |n| "Description #{n}" }
    sequence(:order_price_threshold) { |n| ("#{n}".to_i+1)*25 }
    sequence(:discount_amount) { |n| ("#{n}".to_i+1)*5 }
    active { true }
  end

  factory :inactive_item_discount, parent: :item_discount do
    association :user, factory: :merchant
    sequence(:name) { |n| "Inactive Discount Name #{n}" }
    active { false }
  end
end
