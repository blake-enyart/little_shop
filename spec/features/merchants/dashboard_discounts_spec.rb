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

  describe 'allows me to update a specific discount' do
    before :each do
      @discount = create(:item_discount, user: @merchant, name: 'Discount', description: 'Something witty goes here', order_price_threshold: 50, discount_amount: 5)
    end

    scenario 'when logged in as merchant' do
      describe 'happy path' do
        update_info = build(:item_discount)
        login_as(@merchant)
        visit dashboard_item_discounts_path

        within "#discount-#{@discount.id}" do
          click_link 'Edit Discount'
        end

        expect(current_path).to eq(edit_dashboard_item_discount_path(@discount))
        expect(page.find_field(:name)).to have_content(@discount.name)
        expect(page.find_field(:description)).to have_content(@discount.description)
        expect(page.find_field(:order_price_threshold)).to have_content(@discount.order_price_threshold)
        expect(page.find_field(:discount_amount)).to have_content(@discount.discount_amount)

        fill_in 'Name', with: update_info.name
        fill_in 'Description', with: update_info.description
        fill_in 'Order Price Threshold', with: update_info.order_price_threshold
        fill_in 'Discount Amount', with: update_info.discount_amount
        click_button "Submit"

        expect(current_path).to eq(dashboard_item_discounts_path)
        @discount.reload #update discount details
        
        expect(page).to have_content("#{@discount.name} is now updated!")

        within "#discount-#{@discount.id}" do
          expect(page).to have_content(@discount.name)
          expect(page).to have_content("Description: #{@discount.description}")
          expect(page).to have_content("Order Price Threshold: #{@discount.order_price_threshold}")
          expect(page).to have_content("Discount Amount: #{@discount.discount_amount}")
          expect(page).to have_link("Enable Discount", href: dashboard_enable_item_discount_path(new_discount))
          expect(page).to have_link("Edit Discount")
        end
      end
    end
  end
end
