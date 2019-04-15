require 'rails_helper'

include ActionView::Helpers::NumberHelper

RSpec.describe 'Merchant Dashboard Discounts page' do
  before :each do
    @merchant = create(:merchant)
    @admin = create(:admin)

    @items_list = create_list(:item, 3, user: @merchant)
    @items_list << create(:inactive_item, user: @merchant)

    @discounts_list = create_list(:item_discount, 3, user: @merchant)
    @discounts_list << create(:inactive_item_discount, user: @merchant)

    @order = create(:shipped_order)
    @oi_1 = create(:fulfilled_order_item, order: @order, item: @items_list[0], price: 1, quantity: 1, created_at: 2.hours.ago, updated_at: 50.minutes.ago)
  end

  describe 'allows me to disable then re-enable an active discount' do
    before :each do
      @discount = create(:item_discount, user: @merchant, name: 'Discount', description: 'Something witty goes here', order_price_threshold: 50, discount_amount: 5)
    end

    scenario 'when logged in as merchant' do
      login_as(@merchant)
      visit dashboard_item_discounts_path

      within "#discount-#{@discount.id}" do
        click_link 'Disable Discount'
      end

      expect(current_path).to eq(dashboard_item_discounts_path)

      within "#discount-#{@discount.id}" do
        expect(page).to_not have_link('Disable Discount')
        click_link 'Enable Discount'
      end

      expect(current_path).to eq(dashboard_item_discounts_path)

      within "#discount-#{@discounts_list[0].id}" do
        expect(page).to_not have_link('Enable Discount')
      end
    end
  end
end
