require 'rails_helper'

RSpec.describe Cart do
  describe "Cart with existing contents" do
    before :each do
      @item_1 = create(:item, id: 1)
      @item_4 = create(:item, id: 4)
      @cart = Cart.new({"1" => 3, "4" => 2})
    end

    describe "#total_item_count" do
      it "returns the total item count" do
        expect(@cart.total_item_count).to eq(5)
      end
    end

    describe "#contents" do
      it "returns the contents" do
        expect(@cart.contents).to eq({"1" => 3, "4" => 2})
      end
    end

    describe "#count_of" do
      it "counts a particular item" do
        expect(@cart.count_of(1)).to eq(3)
      end
    end

    describe "#add_item" do
      it "increments an existing item" do
        @cart.add_item(1)
        expect(@cart.count_of(1)).to eq(4)
      end

      it "can increment an item not in the cart yet" do
        @cart.add_item(2)
        expect(@cart.count_of(2)).to eq(1)
      end
    end

    describe "#remove_item" do
      it "decrements an existing item" do
        @cart.remove_item(1)
        expect(@cart.count_of(1)).to eq(2)
      end

      it "deletes an item when count goes to zero" do
        @cart.remove_item(1)
        @cart.remove_item(1)
        @cart.remove_item(1)
        expect(@cart.contents.keys).to_not include("1")
      end
    end

    describe "#items" do
      it "can map item_ids to objects" do

        expect(@cart.items).to eq({@item_1 => 3, @item_4 => 2})
      end
    end

    describe "#total" do
      it "can calculate the total of all items in the cart" do
        expect(@cart.total).to eq(@item_1.price * 3 + @item_4.price * 2)
      end
    end

    describe "#subtotal" do
      it "calculates the total for a single item" do
        expect(@cart.subtotal(@item_1)).to eq(@cart.count_of(@item_1.id) * @item_1.price)
      end
    end
  end

  describe "Cart with empty contents" do
    before :each do
      @cart = Cart.new(nil)
    end

    describe "#total_item_count" do
      it "returns 0 when there are no contents" do
        expect(@cart.total_item_count).to eq(0)
      end
    end

    describe "#contents" do
      it "returns empty contents" do
        expect(@cart.contents).to eq({})
      end
    end

    describe "#count_of" do
      it "counts non existent items as zero" do
        expect(@cart.count_of(1)).to eq(0)
      end
    end

    describe "#add_item" do
      it "increments the item's count" do
        @cart.add_item(2)
        expect(@cart.count_of(2)).to eq(1)
      end
    end
  end

  describe "Cart with discount available" do
    before(:each) do
      @merchant_1 = create(:merchant)
      @merchant_2 = create(:merchant)

      @discount_1 = create(:item_discount, user: @merchant_1, order_price_threshold: 50, discount_amount: 10)

      @item_1 = create(:item, id: 1, user: @merchant_1, price: 25)
      @item_2 = create(:item, id: 2, user: @merchant_1, price: 25)
      @item_4 = create(:item, id: 4, user: @merchant_2, price: 25)
      @item_5 = create(:item, id: 5, user: @merchant_2, price: 25)

      @cart = Cart.new({"1" => 2, "2" => 1, "4" => 2, "5" => 1})
    end

    describe "#total_item_count" do
      it "returns the total item count" do
        expect(@cart.total_item_count).to eq(6)
      end
    end

    describe "#contents" do
      it "returns the contents" do
        actual = @cart.contents
        expected = {"1" => 2, "2" => 1, "4" => 2, "5" => 1}

        expect(actual).to eq(expected)
      end
    end

    describe "#count_of" do
      it "counts a particular item" do
        actual = @cart.count_of(1)
        expected = 2

        expect(@cart.count_of(1)).to eq(2)

        actual = @cart.count_of(2)
        expected = 2

        expect(@cart.count_of(2)).to eq(1)
      end
    end

    describe "#add_item" do
      it "increments an existing item" do
        @cart.add_item(1)
        expect(@cart.count_of(1)).to eq(3)
      end

      it "can increment an item not in the cart yet" do
        @cart.add_item(10)
        expect(@cart.count_of(10)).to eq(1)
      end
    end

    describe "#remove_item" do
      it "decrements an existing item" do
        @cart.remove_item(1)
        expect(@cart.count_of(1)).to eq(1)
      end

      it "deletes an item when count goes to zero" do
        @cart.remove_item(1)
        @cart.remove_item(1)
        expect(@cart.contents.keys).to_not include("1")
      end
    end

    describe "#items" do
      it "can map item_ids to objects" do
        actual = @cart.items
        expected = {@item_1 => 2, @item_2 => 1, @item_4 => 2, @item_5 => 1}

        expect(actual).to eq(expected)
      end
    end

    describe "#total" do
      it "can calculate the total of all items in the cart with discount" do
        actual = @cart.total
        #discount_1 only applied on item_1
        expected = ((@item_1.price * 2) - 10) + @item_2.price * 1 + @item_4.price * 2 \
        + @item_5.price * 1

        expect(actual).to_not eq(expected)
      end

      it "can calculate the total of all items in the cart with multiple discounts available" do
        discount_2 = create(:item_discount, user: @merchant_1, order_price_threshold: 50, discount_amount: 30)

        actual = @cart.total
        #discount_2 only applied on item_1
        expected = ((@item_1.price * 2) - 30) + @item_2.price * 1 + @item_4.price * 2 \
        + @item_5.price * 1
        unexpected = @item_1.price * 2 + @item_2.price * 1 + @item_4.price * 2 \
        + @item_5.price * 1

        expect(actual).to eq(expected)
        expect(actual).to_not eq(unexpected)

        discount_3 = create(:item_discount, user: @merchant_2, order_price_threshold: 50, discount_amount: 10)

        actual = @cart.total
        #discount_2 applied on item_1 and discount_3 applied on item_4
        expected = ((@item_1.price * 2) - 30) + @item_2.price * 1 + ((@item_4.price * 2) - 10) \
        + @item_5.price * 1

        expect(actual).to eq(expected)
      end
    end

    describe "#subtotal" do
      it "calculates the total for a single item with discount" do
        #item_1 belongs to merchant_1 with discount_1
        actual = @cart.subtotal(@item_1)
        expected = (@cart.count_of(@item_1.id) * @item_1.price) - 10

        expect(actual).to eq(expected)
      end

      it "calculates the total for a single item without enough for discount" do
        #item_2 belongs to merchant_1 with discount_1
        actual = @cart.subtotal(@item_2)
        expected = @cart.count_of(@item_2.id) * @item_2.price

        expect(actual).to eq(expected)
      end

      it "calculates the total for a single item with no discount available" do
        #item_4 belongs to merchant_2 without discount_1, but qualifying amount
        actual = @cart.subtotal(@item_4)
        expected = @cart.count_of(@item_4.id) * @item_4.price

        expect(actual).to eq(expected)
        #item_5 belongs to merchant_2 without discount_1 and unqualifying amount
        actual = @cart.subtotal(@item_5)
        expected = @cart.count_of(@item_5.id) * @item_5.price

        expect(actual).to eq(expected)
      end

      it "calculates the total for a single item with multiple discounts available" do
        discount_2 = create(:item_discount, user: @merchant_1, order_price_threshold: 50, discount_amount: 30)
        #item_1 belongs to merchant_1 with discount_1 and discount_2
        actual = @cart.subtotal(@item_1)
        expected = (@cart.count_of(@item_1.id) * @item_1.price) - 30 #chooses largest discount
        unexpected = (@cart.count_of(@item_1.id) * @item_1.price) - 10

        expect(actual).to eq(expected)
        expect(actual).to_not eq(unexpected)
      end
    end
  end
end
