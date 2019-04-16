require 'rails_helper'

include ActionView::Helpers::NumberHelper

RSpec.describe 'Merchant Dashboard Items page' do
  before :each do
    @merchant = create(:merchant)
    @admin = create(:admin)

    @items = create_list(:item, 3, user: @merchant)
    @items << create(:inactive_item, user: @merchant)

    @order = create(:shipped_order)
    @oi_1 = create(:fulfilled_order_item, order: @order, item: @items[0], price: 1, quantity: 1, created_at: 2.hours.ago, updated_at: 50.minutes.ago)
  end

  describe 'allows me to disable then re-enable an active item' do
    before :each do
      @item = create(:item, user: @merchant, name: 'Widget', description: 'Something witty goes here', price: 1.23, inventory: 456)
    end

    scenario 'when logged in as merchant' do
      login_as(@merchant)
      visit dashboard_items_path

      within "#item-#{@item.id}" do
        click_button 'Disable Item'
      end

      expect(current_path).to eq(dashboard_items_path)

      within "#item-#{@item.id}" do
        expect(page).to_not have_button('Disable Item')
        click_button 'Enable Item'
      end

      expect(current_path).to eq(dashboard_items_path)

      within "#item-#{@items[0].id}" do
        expect(page).to_not have_button('Enable Item')
      end
    end
  end

  describe 'when trying to delete an item' do
    describe 'works when nobody has purchased that item before' do
      scenario 'when logged in as merchant' do
        login_as(@merchant)
        visit dashboard_items_path

        within "#item-#{@items[1].id}" do
          click_button 'Delete Item'
        end

        @merchant.reload

        expect(current_path).to eq(dashboard_items_path)
        expect(page).to_not have_css("#item-#{@items[1].id}")
        expect(page).to_not have_content(@items[1].name)
      end
    end

    describe 'fails if someone has purchased that item before' do
      scenario 'when logged in as merchant' do
        login_as(@merchant)
        visit dashboard_items_path

        page.driver.delete(dashboard_item_path(@items[0]))
        expect(page.status_code).to eq(302)

        visit dashboard_items_path

        expect(page).to have_css("#item-#{@items[0].id}")
        expect(page).to have_content("Attempt to delete #{@items[0].name} was thwarted!")
      end
    end
  end

  describe 'other merchants from modifying my items' do
    before :each do
      @bad_merchant = create(:merchant)
      login_as(@bad_merchant)
    end

    it 'fails when trying to delete my item' do
      page.driver.submit :delete, dashboard_item_path(@items[0]), {}
    end

    it 'fails when trying to enable my item' do
      page.driver.submit :patch, dashboard_enable_item_path(@items[0]), {}
    end

    it 'fails when trying to disable my item' do
      page.driver.submit :patch, dashboard_disable_item_path(@items[0]), {}
    end

    after :each do
      expect(page.status_code).to eq(404)
    end
  end
end
