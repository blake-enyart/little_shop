require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_presence_of :password }
    it { should validate_presence_of :name }
    it { should validate_presence_of :address }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
  end

  describe 'relationships' do
    # as user
    it { should have_many :orders }
    it { should have_many(:order_items).through(:orders)}
    # as merchant
    it { should have_many :items }
  end

  describe 'roles' do
    it 'can be created as a default user' do
      user = User.create(
        email: "email",
        password: "password",
        name: "name",
        address: "address",
        city: "city",
        state: "state",
        zip: "zip"
      )
      expect(user.role).to eq('default')
      expect(user.default?).to be_truthy
    end

    it 'can be created as a merchant' do
      user = User.create(
        email: "email",
        password: "password",
        name: "name",
        address: "address",
        city: "city",
        state: "state",
        zip: "zip",
        role: 1
      )
      expect(user.role).to eq('merchant')
      expect(user.merchant?).to be_truthy
    end

    it 'can be created as an admin' do
      user = User.create(
        email: "email",
        password: "password",
        name: "name",
        address: "address",
        city: "city",
        state: "state",
        zip: "zip",
        role: 2
      )
      expect(user.role).to eq('admin')
      expect(user.admin?).to be_truthy
    end
  end

  describe 'instance methods' do
    before :each do
      @u1 = create(:user, state: "CO", city: "Anywhere")
      @u2 = create(:user, state: "OK", city: "Tulsa")
      @u3 = create(:user, state: "IA", city: "Anywhere")
      u4 = create(:user, state: "IA", city: "Des Moines")
      u5 = create(:user, state: "IA", city: "Des Moines")
      u6 = create(:user, state: "IA", city: "Des Moines")

      @m1 = create(:merchant)
      @i1 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i2 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i3 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i4 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i5 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i6 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i7 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i8 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i9 = create(:inactive_item, merchant_id: @m1.id)

      @m2 = create(:merchant)
      @i10 = create(:item, merchant_id: @m2.id, inventory: 20)

      o1 = create(:shipped_order, user: @u1)
      o2 = create(:shipped_order, user: @u2)
      o3 = create(:shipped_order, user: @u3)
      o4 = create(:shipped_order, user: @u1)
      o5 = create(:shipped_order, user: @u1)
      o6 = create(:cancelled_order, user: u5)
      o7 = create(:order, user: u6)
      @oi1 = create(:order_item, item: @i1, order: o1, quantity: 2, created_at: 1.days.ago)
      @oi2 = create(:order_item, item: @i2, order: o2, quantity: 8, created_at: 7.days.ago)
      @oi3 = create(:order_item, item: @i2, order: o3, quantity: 6, created_at: 7.days.ago)
      @oi4 = create(:order_item, item: @i3, order: o3, quantity: 4, created_at: 6.days.ago)
      @oi5 = create(:order_item, item: @i4, order: o4, quantity: 3, created_at: 4.days.ago)
      @oi6 = create(:order_item, item: @i5, order: o5, quantity: 1, created_at: 5.days.ago)
      @oi7 = create(:order_item, item: @i6, order: o6, quantity: 2, created_at: 3.days.ago)
      @oi1.fulfill
      @oi2.fulfill
      @oi3.fulfill
      @oi4.fulfill
      @oi5.fulfill
      @oi6.fulfill
      @oi7.fulfill
    end

    it '.active_items' do
      expect(@m2.active_items).to eq([@i10])
      expect(@m1.active_items).to eq([@i1, @i2, @i3, @i4, @i5, @i6, @i7, @i8])
    end

    it '.top_items_sold_by_quantity' do
      expect(@m1.top_items_sold_by_quantity(5).length).to eq(5)
      expect(@m1.top_items_sold_by_quantity(5)[0].name).to eq(@i2.name)
      expect(@m1.top_items_sold_by_quantity(5)[0].quantity).to eq(14)
      expect(@m1.top_items_sold_by_quantity(5)[1].name).to eq(@i3.name)
      expect(@m1.top_items_sold_by_quantity(5)[1].quantity).to eq(4)
      expect(@m1.top_items_sold_by_quantity(5)[2].name).to eq(@i4.name)
      expect(@m1.top_items_sold_by_quantity(5)[2].quantity).to eq(3)
      expect(@m1.top_items_sold_by_quantity(5)[3].name).to eq(@i1.name)
      expect(@m1.top_items_sold_by_quantity(5)[3].quantity).to eq(2)
      expect(@m1.top_items_sold_by_quantity(5)[4].name).to eq(@i5.name)
      expect(@m1.top_items_sold_by_quantity(5)[4].quantity).to eq(1)
    end

    it '.total_items_sold' do
      expect(@m1.total_items_sold).to eq(24)
    end

    it '.percent_of_items_sold' do
      expect(@m1.percent_of_items_sold.round(2)).to eq(17.39)
    end

    it '.total_inventory_remaining' do
      expect(@m1.total_inventory_remaining).to eq(138)
    end

    it '.top_states_by_items_shipped' do
      expect(@m1.top_states_by_items_shipped(3)[0].state).to eq("IA")
      expect(@m1.top_states_by_items_shipped(3)[0].quantity).to eq(10)
      expect(@m1.top_states_by_items_shipped(3)[1].state).to eq("OK")
      expect(@m1.top_states_by_items_shipped(3)[1].quantity).to eq(8)
      expect(@m1.top_states_by_items_shipped(3)[2].state).to eq("CO")
      expect(@m1.top_states_by_items_shipped(3)[2].quantity).to eq(6)
    end

    it '.top_cities_by_items_shipped' do
      expect(@m1.top_cities_by_items_shipped(3)[0].city).to eq("Anywhere")
      expect(@m1.top_cities_by_items_shipped(3)[0].state).to eq("IA")
      expect(@m1.top_cities_by_items_shipped(3)[0].quantity).to eq(10)
      expect(@m1.top_cities_by_items_shipped(3)[1].city).to eq("Tulsa")
      expect(@m1.top_cities_by_items_shipped(3)[1].state).to eq("OK")
      expect(@m1.top_cities_by_items_shipped(3)[1].quantity).to eq(8)
      expect(@m1.top_cities_by_items_shipped(3)[2].city).to eq("Anywhere")
      expect(@m1.top_cities_by_items_shipped(3)[2].state).to eq("CO")
      expect(@m1.top_cities_by_items_shipped(3)[2].quantity).to eq(6)
    end

    it '.top_users_by_money_spent' do
      expect(@m1.top_users_by_money_spent(3)[0].name).to eq(@u3.name)
      expect(@m1.top_users_by_money_spent(3)[0].total.to_f).to eq(66.00)
      expect(@m1.top_users_by_money_spent(3)[1].name).to eq(@u1.name)
      expect(@m1.top_users_by_money_spent(3)[1].total.to_f).to eq(43.50)
      expect(@m1.top_users_by_money_spent(3)[2].name).to eq(@u2.name)
      expect(@m1.top_users_by_money_spent(3)[2].total.to_f).to eq(36.00)
    end

    it '.top_user_by_order_count' do
      expect(@m1.top_user_by_order_count.name).to eq(@u1.name)
      expect(@m1.top_user_by_order_count.count).to eq(3)
    end

    it '.top_user_by_item_count' do
      expect(@m1.top_user_by_item_count.name).to eq(@u3.name)
      expect(@m1.top_user_by_item_count.quantity).to eq(10)
    end
  end

  describe 'class methods' do
    it ".active_merchants" do
      active_merchants = create_list(:merchant, 3)
      inactive_merchant = create(:inactive_merchant)

      expect(User.active_merchants).to eq(active_merchants)
    end

    it '.default_users' do
      users = create_list(:user, 3)
      merchant = create(:merchant)
      admin = create(:admin)

      expect(User.default_users).to eq(users)
    end

    describe "statistics" do
      before :each do
        u1 = create(:user, state: "CO", city: "Fairfield")
        u2 = create(:user, state: "OK", city: "OKC")
        u3 = create(:user, state: "IA", city: "Fairfield")
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
        o1 = create(:shipped_order, user: u1)
        o2 = create(:shipped_order, user: u2)
        o3 = create(:shipped_order, user: u3)
        o4 = create(:shipped_order, user: u1)
        o5 = create(:cancelled_order, user: u5)
        o6 = create(:shipped_order, user: u6)
        o7 = create(:shipped_order, user: u6)
        oi1 = create(:fulfilled_order_item, item: i1, order: o1, created_at: 1.days.ago)
        oi2 = create(:fulfilled_order_item, item: i2, order: o2, created_at: 7.days.ago)
        oi3 = create(:fulfilled_order_item, item: i3, order: o3, created_at: 6.days.ago)
        oi4 = create(:order_item, item: i4, order: o4, created_at: 4.days.ago)
        oi5 = create(:order_item, item: i5, order: o5, created_at: 5.days.ago)
        oi6 = create(:fulfilled_order_item, item: i6, order: o6, created_at: 3.days.ago)
        oi7 = create(:fulfilled_order_item, item: i7, order: o7, created_at: 2.days.ago)
      end

      it ".merchants_sorted_by_revenue" do
        expect(User.merchants_sorted_by_revenue).to eq([@m7, @m6, @m3, @m2, @m1])
      end

      it ".top_merchants_by_revenue()" do
        expect(User.top_merchants_by_revenue(3)).to eq([@m7, @m6, @m3])
      end

      it ".merchants_sorted_by_fulfillment_time" do
        expect(User.merchants_sorted_by_fulfillment_time(1).length).to eq(1)
        expect(User.merchants_sorted_by_fulfillment_time(10).length).to eq(5)
        expect(User.merchants_sorted_by_fulfillment_time(10)).to eq([@m1, @m7, @m6, @m3, @m2])
      end

      it ".top_merchants_by_fulfillment_time" do
        expect(User.top_merchants_by_fulfillment_time(3)).to eq([@m1, @m7, @m6])
      end

      it ".bottom_merchants_by_fulfillment_time" do
        expect(User.bottom_merchants_by_fulfillment_time(3)).to eq([@m2, @m3, @m6])
      end

      it ".top_user_states_by_order_count" do
        expect(User.top_user_states_by_order_count(3)[0].state).to eq("IA")
        expect(User.top_user_states_by_order_count(3)[0].order_count).to eq(3)
        expect(User.top_user_states_by_order_count(3)[1].state).to eq("CO")
        expect(User.top_user_states_by_order_count(3)[1].order_count).to eq(2)
        expect(User.top_user_states_by_order_count(3)[2].state).to eq("OK")
        expect(User.top_user_states_by_order_count(3)[2].order_count).to eq(1)
      end

      it ".top_user_cities_by_order_count" do
        expect(User.top_user_cities_by_order_count(3)[0].state).to eq("CO")
        expect(User.top_user_cities_by_order_count(3)[0].city).to eq("Fairfield")
        expect(User.top_user_cities_by_order_count(3)[0].order_count).to eq(2)
        expect(User.top_user_cities_by_order_count(3)[1].state).to eq("IA")
        expect(User.top_user_cities_by_order_count(3)[1].city).to eq("Des Moines")
        expect(User.top_user_cities_by_order_count(3)[1].order_count).to eq(2)
        expect(User.top_user_cities_by_order_count(3)[2].state).to eq("IA")
        expect(User.top_user_cities_by_order_count(3)[2].city).to eq("Fairfield")
        expect(User.top_user_cities_by_order_count(3)[2].order_count).to eq(1)
      end
    end

    describe 'leaderboard stats' do
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

        it '.top_selling_merchants_current' do
          actual = User.top_selling_merchants_current(10)
                      #m11 and m12 tied for first
          expected_merchant_order = [@m[11], #query sorts alphabetically
                                     @m[12], #sum multiple orders of same month
                                     @m[10],
                                     @m[9],
                                     @m[8],
                                     @m[7],
                                     @m[6],
                                     @m[5],
                                     @m[4],
                                     @m[3]]
          actual_quantity_sold = []
          actual.each do |record|
            actual_quantity_sold << record.quantity_sold
          end

          expected_quantity_sold_order = [@oi_new_11.quantity, #query sorts alphabetically
                                          100, #sum multiple orders of same month
                                          @oi_new_10.quantity,
                                          @oi_new_9.quantity,
                                          @oi_new_8.quantity,
                                          @oi_new_7.quantity,
                                          @oi_new_6.quantity,
                                          @oi_new_5.quantity,
                                          @oi_new_4.quantity,
                                          @oi_new_3.quantity]

          expect(actual).to eq(expected_merchant_order)
          expect(actual_quantity_sold).to eq(expected_quantity_sold_order)
        end

        it '.top_selling_merchants_previous' do
          actual = User.top_selling_merchants_previous(10)
                      #m11 and m12 tied for first
          expected_merchant_order = [@m[1],
                                     @m[2],
                                     @m[3],
                                     @m[4],
                                     @m[5],
                                     @m[6],
                                     @m[7],
                                     @m[8],
                                     @m[9],
                                     @m[10]]
          actual_quantity_sold = []
          actual.each do |record|
            actual_quantity_sold << record.quantity_sold
          end

          expected_quantity_sold_order = [100, #sum multiple orders of same month
                                          @oi_old_11.quantity,
                                          @oi_old_10.quantity,
                                          @oi_old_9.quantity,
                                          @oi_old_8.quantity,
                                          @oi_old_7.quantity,
                                          @oi_old_6.quantity,
                                          @oi_old_5.quantity,
                                          @oi_old_4.quantity,
                                          @oi_old_3.quantity]

          expect(actual).to eq(expected_merchant_order)
          expect(actual_quantity_sold).to eq(expected_quantity_sold_order)
        end
      end

      describe 'top fulfillment' do
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

        it '.top_fulfilled_packaged_orders_current' do
          actual = User.top_fulfilled_non_cancelled_orders_current(10)

          expected_merchant_order = \
          [@m[20],@m[11],@m[12],@m[13],@m[14],@m[15],@m[16],@m[17],@m[18],@m[19]]

          actual_completed_orders = []
          actual.each do |record|
            actual_completed_orders << record.completed_orders
          end

          expected_completed_orders = [2,1,1,1,1,1,1,1,1,1]

          expect(actual).to eq(expected_merchant_order)
          expect(actual_completed_orders).to eq(expected_completed_orders)
        end
      end
    end
  end
end
