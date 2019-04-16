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

  context 'when logged in as merchant' do
    describe 'happy path' do
      before :each do
        @discount = create(:inactive_item_discount, user: @merchant, name: 'Discount', description: 'Something witty goes here', order_price_threshold: 50, discount_amount: 5)
      end

      it 'allows me to update a specific discount' do

        update_info = build(:item_discount)
        login_as(@merchant)
        visit dashboard_item_discounts_path

        within "#discount-#{@discount.id}" do
          click_link 'Edit Discount'
        end

        expect(current_path).to eq(edit_dashboard_item_discount_path(@discount))

        expect(find_field('Name').value).to have_content(@discount.name)
        expect(find_field('Description').value).to have_content(@discount.description)
        expect(find_field('Order Price Threshold').value).to have_content(@discount.order_price_threshold)
        expect(find_field('Discount Amount').value).to have_content(@discount.discount_amount)

        fill_in 'Name', with: update_info.name
        fill_in 'Description', with: update_info.description
        fill_in 'Order Price Threshold', with: update_info.order_price_threshold
        fill_in 'Discount Amount', with: update_info.discount_amount
        click_button "Submit"

        expect(current_path).to eq(dashboard_item_discounts_path)

        expect(page).to have_content("#{update_info.name} is now updated!")

        within "#discount-#{@discount.id}" do
          expect(page).to have_content(update_info.name)
          expect(page).to have_content("Description: #{update_info.description}")
          expect(page).to have_content("Order Price Threshold: #{update_info.order_price_threshold}")
          expect(page).to have_content("Discount Amount: #{update_info.discount_amount}")
          expect(page).to have_link("Enable Discount", href: dashboard_enable_item_discount_path(@discount))
          expect(page).to have_link("Edit Discount")
        end
      end

      it 'allows me to delete a specific discount' do
        update_info = build(:item_discount)
        login_as(@merchant)
        visit dashboard_item_discounts_path

        within "#discount-#{@discount.id}" do
          click_link 'Delete Discount'
        end

        expect(current_path).to eq(dashboard_item_discounts_path)
        expect(page).to have_content('Your discount has been deleted.')
        expect(page).to_not have_css("#discount-#{@discount.id}")
      end
    end
  end
end
