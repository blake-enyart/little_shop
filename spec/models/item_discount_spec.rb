require 'rails_helper'

RSpec.describe ItemDiscount, type: :model do
  describe 'validation(s)' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :order_price_threshold }
    it { should validate_presence_of :discount_amount }
  end

  describe 'relationship(s)' do
    it { should belong_to :user }
  end
end
