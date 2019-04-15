require 'rails_helper'

RSpec.describe "Merchant adding an discount" do
  before :each do
    @merchant = create(:merchant)
    login_as(@merchant)
    click_link 'Discounts'
  end

  it "creates a discount" do
    expect(current_path).to eq(dashboard_item_discounts_path)

    new_name = "discount 1"
    new_description = "$5 off $50 in order"
    new_order_price_threshold = 50
    new_discount_amount = 5

    click_link "Add New Discount"

    expect(current_path).to eq(new_dashboard_item_discount_path)

    fill_in 'Name', with: new_name
    fill_in 'Description', with: new_description
    fill_in 'Order Price Threshold', with: new_order_price_threshold
    fill_in 'Discount Amount', with: new_discount_amount
    click_button "Create Discount"

    new_discount = ItemDiscount.last

    expect(current_path).to eq(dashboard_item_discounts_path)
    expect(page).to have_content("Your discount has been saved!")

    within "#discount-#{new_discount.id}" do
      expect(page).to have_content(new_name)
      expect(page).to have_content("Description: #{new_description}")
      expect(page).to have_content("Order Price Threshold: #{new_order_price_threshold}")
      expect(page).to have_content("Discount Amount: #{new_discount_amount}")
      expect(page).to have_link("Enable Discount", href: dashboard_enable_item_discount_path(new_discount))
    end
  end
end
