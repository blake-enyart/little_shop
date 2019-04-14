require 'rails_helper'

RSpec.describe "merchant index workflow", type: :feature do
  describe "As a visitor" do
    describe "displays all active merchant information" do
      before :each do
        @merchant_1, @merchant_2 = create_list(:merchant, 2)
        @inactive_merchant = create(:inactive_merchant)
      end
      scenario 'as a visitor' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
        @am_admin = false
      end
      scenario 'as an admin' do
        admin = create(:admin)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
        @am_admin = true
      end
      after :each do
        visit merchants_path

        within("#merchant-#{@merchant_1.id}") do
          expect(page).to have_content(@merchant_1.name)
          expect(page).to have_content("#{@merchant_1.city}, #{@merchant_1.state}")
          expect(page).to have_content("Registered Date: #{@merchant_1.created_at}")
          if @am_admin
            expect(page).to have_button('Disable Merchant')
          end
        end

        within("#merchant-#{@merchant_2.id}") do
          expect(page).to have_content(@merchant_2.name)
          expect(page).to have_content("#{@merchant_2.city}, #{@merchant_2.state}")
          expect(page).to have_content("Registered Date: #{@merchant_2.created_at}")
          if @am_admin
            expect(page).to have_button('Disable Merchant')
          end
        end

        if @am_admin
          within("#merchant-#{@inactive_merchant.id}") do
            expect(page).to have_button('Enable Merchant')
          end
        else
          expect(page).to_not have_content(@inactive_merchant.name)
          expect(page).to_not have_content("#{@inactive_merchant.city}, #{@inactive_merchant.state}")
        end
      end
    end

    describe 'admins can enable/disable merchants' do
      before :each do
        @merchant_1 = create(:merchant)
        @admin = create(:admin)
      end
      it 'allows an admin to disable a merchant' do
        login_as(@admin)

        visit merchants_path

        within("#merchant-#{@merchant_1.id}") do
          click_button('Disable Merchant')
        end
        expect(current_path).to eq(merchants_path)

        visit logout_path
        login_as(@merchant_1)
        expect(current_path).to eq(login_path)
        expect(page).to have_content('Your account is inactive, contact an admin for help')

        visit logout_path
        login_as(@admin)
        visit merchants_path

        within("#merchant-#{@merchant_1.id}") do
          click_button('Enable Merchant')
        end

        visit logout_path
        login_as(@merchant_1)
        expect(current_path).to eq(dashboard_path)

        visit logout_path
        login_as(@admin)
        visit merchants_path

        within("#merchant-#{@merchant_1.id}") do
          expect(page).to have_button('Disable Merchant')
        end
      end
    end

    describe "shows merchant statistics" do
      before :each do
        u1 = create(:user, state: "CO", city: "Fairfield")
        u3 = create(:user, state: "IA", city: "Fairfield")
        u2 = create(:user, state: "OK", city: "OKC")
        u4 = create(:user, state: "IA", city: "Des Moines")
        u5 = create(:user, state: "IA", city: "Des Moines")
        u6 = create(:user, state: "IA", city: "Des Moines")
        @m1, @m2, @m3, @m4, @m5, @m6, @m7 = create_list(:merchant, 7)
        i1 = create(:item, merchant_id: @m1.id)
        i2 = create(:item, merchant_id: @m2.id)
        i3 = create(:item, merchant_id: @m3.id)
        i4 = create(:item, merchant_id: @m4.id)
        i5 = create(:item, merchant_id: @m5.id)
        i6 = create(:item, merchant_id: @m6.id)
        i7 = create(:item, merchant_id: @m7.id)
        @o1 = create(:shipped_order, user: u1)
        @o2 = create(:shipped_order, user: u2)
        @o3 = create(:shipped_order, user: u3)
        @o4 = create(:shipped_order, user: u1)
        @o5 = create(:cancelled_order, user: u5)
        @o6 = create(:shipped_order, user: u6)
        @o7 = create(:shipped_order, user: u6)
        oi1 = create(:fulfilled_order_item, item: i1, order: @o1, created_at: 5.minutes.ago)
        oi2 = create(:fulfilled_order_item, item: i2, order: @o2, created_at: 53.5.hours.ago)
        oi3 = create(:fulfilled_order_item, item: i3, order: @o3, created_at: 6.days.ago)
        oi4 = create(:order_item, item: i4, order: @o4, created_at: 4.days.ago)
        oi5 = create(:order_item, item: i5, order: @o5, created_at: 5.days.ago)
        oi6 = create(:fulfilled_order_item, item: i6, order: @o6, created_at: 3.days.ago)
        oi7 = create(:fulfilled_order_item, item: i7, order: @o7, created_at: 2.hours.ago)
      end

      it "top 3 merchants by price and quantity, with their revenue" do
        visit merchants_path

        within("#top-three-merchants-revenue") do
          expect(page).to have_content("#{@m7.name}: $192.00")
          expect(page).to have_content("#{@m6.name}: $147.00")
          expect(page).to have_content("#{@m3.name}: $48.00")
        end
      end

      it "top 3 merchants who were fastest at fulfilling items in an order, with their times" do
        visit merchants_path

        within("#top-three-merchants-fulfillment") do
          expect(page).to have_content("#{@m1.name}: 00 hours 05 minutes")
          expect(page).to have_content("#{@m7.name}: 02 hours 00 minutes")
          expect(page).to have_content("#{@m2.name}: 2 days 05 hours 30 minutes")
        end
      end

      it "worst 3 merchants who were slowest at fulfilling items in an order, with their times" do
        visit merchants_path

        within("#bottom-three-merchants-fulfillment") do
          expect(page).to have_content("#{@m3.name}: 6 days 00 hours 00 minutes")
          expect(page).to have_content("#{@m6.name}: 3 days 00 hours 00 minutes")
          expect(page).to have_content("#{@m2.name}: 2 days 05 hours 30 minutes")
        end
      end

      it "top 3 states where any orders were shipped, and count of orders" do
        visit merchants_path

        within("#top-states-by-order") do
          expect(page).to have_content("IA: 3 orders")
          expect(page).to have_content("CO: 2 orders")
          expect(page).to have_content("OK: 1 order")
          expect(page).to_not have_content("OK: 1 orders")
        end
      end

      it "top 3 cities where any orders were shipped, and count of orders" do
        visit merchants_path

        within("#top-cities-by-order") do
          expect(page).to have_content("Des Moines, IA: 2 orders")
          expect(page).to have_content("Fairfield, CO: 2 orders")
          expect(page).to have_content("Fairfield, IA: 1 order")
          expect(page).to_not have_content("Fairfield, IA: 1 orders")
        end
      end

      it "top 3 orders by quantity of items shipped, plus their quantities" do
        visit merchants_path

        within("#top-orders-by-items-shipped") do
          expect(page).to have_content("Order #{@o7.id}: 16 items")
          expect(page).to have_content("Order #{@o6.id}: 14 items")
          expect(page).to have_content("Order #{@o3.id}: 8 items")
        end
      end
    end

    describe "shows merchant leaderboard statistics" do
      describe 'top sellers' do
        before :each do
          #generates hash of specified number of merchants
          merchant_list = create_list(:merchant, 12)
          @m = Hash.new
          merchant_list.each_with_index do |merchant, index|
            @m[index+1] = merchant
          end

          #merchants all have enough inventory to complete all orders
          i1 = create(:item, merchant_id: @m[1].id, inventory: 1000)
          i2 = create(:item, merchant_id: @m[2].id, inventory: 1000)
          i3 = create(:item, merchant_id: @m[3].id, inventory: 1000)
          i4 = create(:item, merchant_id: @m[4].id, inventory: 1000)
          i5 = create(:item, merchant_id: @m[5].id, inventory: 1000)
          i6 = create(:item, merchant_id: @m[6].id, inventory: 1000)
          i7 = create(:item, merchant_id: @m[7].id, inventory: 1000)
          i8 = create(:item, merchant_id: @m[8].id, inventory: 1000)
          i9 = create(:item, merchant_id: @m[9].id, inventory: 1000)
          i10 = create(:item, merchant_id: @m[10].id, inventory: 1000)
          i11 = create(:item, merchant_id: @m[11].id, inventory: 1000)
          i12 = create(:item, merchant_id: @m[12].id, inventory: 1000)

          #items are not considered sold until their order is shipped
          #generates hash of specified number of new shipped orders
          new_order_list = create_list(:shipped_order, 13)
          @s_order_new = Hash.new
          new_order_list.each_with_index do |order, index|
            @s_order_new[index+1] = order
          end

          #generates hash of specified number of shipped orders one month old
          old_order_list = create_list(:shipped_order, 13, updated_at: 1.months.ago)
          @s_order_old = Hash.new
          old_order_list.each_with_index do |order, index|
            @s_order_old[index+1] = order
          end

          #order_item is fulfilled and order is shipped and each item belongs to respective
          #merchant of associated number
          #merchants 11,12 sold the most and merchants 1,2 sold the least for recent month
          #tie for least quantity sold and different merchants
          @oi_new_1 = create(:fulfilled_order_item, item: i1, order: @s_order_new[1], quantity: 1)
          @oi_new_2 = create(:fulfilled_order_item, item: i2, order: @s_order_new[2], quantity: 1)

          @oi_new_3 = create(:fulfilled_order_item, item: i3, order: @s_order_new[3])
          @oi_new_4 = create(:fulfilled_order_item, item: i4, order: @s_order_new[4])
          @oi_new_5 = create(:fulfilled_order_item, item: i5, order: @s_order_new[5])
          @oi_new_6 = create(:fulfilled_order_item, item: i6, order: @s_order_new[6])
          @oi_new_7 = create(:fulfilled_order_item, item: i7, order: @s_order_new[7])
          @oi_new_8 = create(:fulfilled_order_item, item: i8, order: @s_order_new[8])
          @oi_new_9 = create(:fulfilled_order_item, item: i9, order: @s_order_new[9])
          @oi_new_10 = create(:fulfilled_order_item, item: i10, order: @s_order_new[10])
          #tie for most quantity sold and different merchants
          @oi_new_11 = create(:fulfilled_order_item, item: i11, order: @s_order_new[11], quantity: 100)
          #tie for most with two orders by same merchant
          @oi_new_12 = create(:fulfilled_order_item, item: i12, order: @s_order_new[12], quantity: 50)
          @oi_new_13 = create(:fulfilled_order_item, item: i12, order: @s_order_new[13], quantity: 50)

          #merchant 1,2 sold the most and merchant 11,12 sold the least for last month
          #tie for least quantity sold and different merchants
          @oi_old_1 = create(:fulfilled_order_item, item: i12, order: @s_order_old[1], quantity: 1)
          @oi_old_2 = create(:fulfilled_order_item, item: i11, order: @s_order_old[2], quantity: 1)

          @oi_old_3 = create(:fulfilled_order_item, item: i10, order: @s_order_old[3])
          @oi_old_4 = create(:fulfilled_order_item, item: i9, order: @s_order_old[4])
          @oi_old_5 = create(:fulfilled_order_item, item: i8, order: @s_order_old[5])
          @oi_old_6 = create(:fulfilled_order_item, item: i7, order: @s_order_old[6])
          @oi_old_7 = create(:fulfilled_order_item, item: i6, order: @s_order_old[7])
          @oi_old_8 = create(:fulfilled_order_item, item: i5, order: @s_order_old[8])
          @oi_old_9 = create(:fulfilled_order_item, item: i4, order: @s_order_old[9])
          @oi_old_10 = create(:fulfilled_order_item, item: i3, order: @s_order_old[10])
          #tie for most quantity sold and different merchants
          @oi_old_11 = create(:fulfilled_order_item, item: i2, order: @s_order_old[11], quantity: 100)
          #tie for most with two orders by same merchant
          @oi_old_12 = create(:fulfilled_order_item, item: i1, order: @s_order_old[12], quantity: 50)
          @oi_old_13 = create(:fulfilled_order_item, item: i1, order: @s_order_old[13], quantity: 50)
        end

        it 'Top 10 Merchants who sold the most items this month' do
          visit merchants_path

          within("#top-ten-sellers-current-month") do
            expect(page).to have_content("#{@m[12].name}: 100")
            expect(page).to have_content("#{@m[11].name}: #{@oi_new_11.quantity}")
            expect(page).to have_content("#{@m[10].name}: #{@oi_new_10.quantity}")
            expect(page).to have_content("#{@m[9].name}: #{@oi_new_9.quantity}")
            expect(page).to have_content("#{@m[8].name}: #{@oi_new_8.quantity}")
            expect(page).to have_content("#{@m[7].name}: #{@oi_new_7.quantity}")
            expect(page).to have_content("#{@m[6].name}: #{@oi_new_6.quantity}")
            expect(page).to have_content("#{@m[5].name}: #{@oi_new_5.quantity}")
            expect(page).to have_content("#{@m[4].name}: #{@oi_new_4.quantity}")
            expect(page).to have_content("#{@m[3].name}: #{@oi_new_3.quantity}")

            expect(page).to_not have_content("#{@m[2].name}: #{@oi_new_2.quantity}")
            expect(page).to_not have_content("#{@m[1].name}: #{@oi_new_1.quantity}")
          end
        end

        it 'Top 10 Merchants who sold the most items last month' do
          visit merchants_path

          within("#top-ten-sellers-previous-month") do
            expect(page).to have_content("#{@m[1].name}: 100")
            expect(page).to have_content("#{@m[2].name}: #{@oi_old_11.quantity}")
            expect(page).to have_content("#{@m[3].name}: #{@oi_old_10.quantity}")
            expect(page).to have_content("#{@m[4].name}: #{@oi_old_9.quantity}")
            expect(page).to have_content("#{@m[5].name}: #{@oi_old_8.quantity}")
            expect(page).to have_content("#{@m[6].name}: #{@oi_old_7.quantity}")
            expect(page).to have_content("#{@m[7].name}: #{@oi_old_6.quantity}")
            expect(page).to have_content("#{@m[8].name}: #{@oi_old_5.quantity}")
            expect(page).to have_content("#{@m[9].name}: #{@oi_old_4.quantity}")
            expect(page).to have_content("#{@m[10].name}: #{@oi_old_3.quantity}")

            expect(page).to_not have_content("#{@m[11].name}: #{@oi_old_2.quantity}")
            expect(page).to_not have_content("#{@m[12].name}: #{@oi_old_1.quantity}")
          end
        end
      end

      describe 'top fulfullment' do
        before(:each) do
          number_of_elements = 21
          #generates hash of 21 of merchants
          merchant_list = create_list(:merchant, number_of_elements)
          @m = Hash.new
          merchant_list.each_with_index do |merchant, index|
            @m[index+1] = merchant
          end

          #generates hash with 21 items associated with corresponding merchant
          @i = Hash.new
          @m.each do |id, merchant|
            @i[id] = create(:item, merchant_id: merchant.id, inventory: 1000)
          end

          #generates hash of 11 new packaged orders
          new_p_order_list = create_list(:packaged_order, 11)
          @p_order_new = Hash.new
          new_p_order_list.each_with_index do |order, index|
            @p_order_new[index+1] = order
          end

          #generates hash of 11 packaged orders one month old
          old_p_order_list = create_list(:packaged_order, 11, updated_at: 1.months.ago)
          @p_order_old = Hash.new
          old_p_order_list.each_with_index do |order, index|
            @p_order_old[index+1] = order
          end

          #generates hash of 11 new cancelled orders
          new_c_order_list = create_list(:cancelled_order, 11)
          @c_order_new = Hash.new
          new_c_order_list.each_with_index do |order, index|
            @c_order_new[index+1] = order
          end

          #generates hash of 11 cancelled orders one month old
          old_c_order_list = create_list(:cancelled_order, 11, updated_at: 1.months.ago)
          @c_order_old = Hash.new
          old_c_order_list.each_with_index do |order, index|
            @c_order_old[index+1] = order
          end

          #generates hash of 8 new order_items associated with corresponding cancelled order(1-8) and item(1-8)
          #merchant 10 fulfilled the most then 9-1 alphabetically because same amount of orders fulfilled.
          @c_oi_new = Hash.new
          @c_order_new.each do |id, new_c_order|
            @c_oi_new[id] = create(:fulfilled_order_item, item: @i[id], order: @c_order_new[id])
            break if id == 8
          end
          @c_oi_new[9] = create(:fulfilled_order_item, item: @i[9], order: @c_order_new[9], quantity: 100)
          @c_oi_new[10] = create(:fulfilled_order_item, item: @i[10], order: @c_order_new[10], quantity: 50)
          @c_oi_new[11] = create(:fulfilled_order_item, item: @i[10], order: @c_order_new[11], quantity: 50)
          FactoryBot.reload #reset sequence for all factories

          #generates hash of 8 new order_items associated with corresponding packaged order(1-8) and item(11-18)
          #merchant 20 first with 19-11 in alphabetical order because same amount of orders fulfilled.
          @p_oi_new = Hash.new
          @p_order_new.each do |id, new_p_order|
            @p_oi_new[id] = create(:fulfilled_order_item, item: @i[10+id], order: @p_order_new[id])
            break if id == 8
          end
          @p_oi_new[9] = create(:fulfilled_order_item, item: @i[19], order: @p_order_new[9], quantity: 100)
          @p_oi_new[10] = create(:fulfilled_order_item, item: @i[20], order: @p_order_new[10], quantity: 50)
          @p_oi_new[11] = create(:fulfilled_order_item, item: @i[20], order: @p_order_new[11], quantity: 50)
          FactoryBot.reload #reset sequence for all factories

          #generates hash of 8 old order_items associated with corresponding one month old cancelled order(1-8) and item(1-8)
          #merchant 1 first with 2-10 in alphabetical order because same amount of orders fulfilled.
          @c_oi_old = Hash.new
          @c_order_old.each do |id, old_c_order|
            @c_oi_old[id] = create(:fulfilled_order_item, item: @i[number_of_elements+1-(id+10)], order: @c_order_old[id])
            break if id == 8
          end
          @c_oi_old[9] = create(:fulfilled_order_item, item: @i[2], order: @c_order_old[9], quantity: 100)
          @c_oi_old[10] = create(:fulfilled_order_item, item: @i[1], order: @c_order_old[10], quantity: 50)
          @c_oi_old[11] = create(:fulfilled_order_item, item: @i[1], order: @c_order_old[11], quantity: 50)
          FactoryBot.reload #reset sequence for all factories

          #generates hash of 8 old order_items associated with corresponding one month old packaged order(1-8) and item(11-18)
          #merchant 11 1st with 12-20 in alphabetical order because same amount of orders fulfilled in previous month
          @p_oi_old = Hash.new
          @p_order_old.each do |id, old_p_order|
            @p_oi_old[id] = create(:fulfilled_order_item, item: @i[number_of_elements+1-id], order: @p_order_old[id])
            break if id == 8
          end
          @p_oi_old[9] = create(:fulfilled_order_item, item: @i[12], order: @p_order_old[9], quantity: 100)
          @p_oi_old[10] = create(:fulfilled_order_item, item: @i[11], order: @p_order_old[10], quantity: 50)
          @p_oi_old[11] = create(:fulfilled_order_item, item: @i[11], order: @p_order_old[11], quantity: 50)
          #In summary, merchants 11-20 are associated with packaged orders and merchants 1-10 are associated with cancelled orders. Merchant 21 is associated with no orders.
        end

        it 'Top 10 Merchants who fulfilled non-cancelled orders this month' do
          visit merchants_path

          within("#top-ten-fulfilled-current-month") do
            expect(page).to have_content("#{@m[20].name}: 2")
            expect(page).to have_content("#{@m[19].name}: 1")
            expect(page).to have_content("#{@m[18].name}: 1")
            expect(page).to have_content("#{@m[17].name}: 1")
            expect(page).to have_content("#{@m[16].name}: 1")
            expect(page).to have_content("#{@m[15].name}: 1")
            expect(page).to have_content("#{@m[14].name}: 1")
            expect(page).to have_content("#{@m[13].name}: 1")
            expect(page).to have_content("#{@m[12].name}: 1")
            expect(page).to have_content("#{@m[11].name}: 1")

            expect(page).to_not have_content(@m[21].name)
          end
        end
      end
    end
  end
end
