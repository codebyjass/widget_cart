require 'rails_helper'

RSpec.describe Offer do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:target_code) }
    it { should validate_inclusion_of(:active).in_array([true, false]) }
  end

  describe 'STI' do
    it 'creates correct subclass instances' do
      bulk_offer = create(:bulk_percentage_discount)
      bogo_offer = create(:buy_one_second_half_price)

      expect(bulk_offer).to be_a(Offer::BulkPercentageDiscount)
      expect(bogo_offer).to be_a(Offer::BuyOneSecondHalfPrice)
    end
  end

  describe 'scopes' do
    it 'returns only active offers' do
      active_offer = create(:bulk_percentage_discount, active: true)
      inactive_offer = create(:bulk_percentage_discount, active: false)

      expect(Offer.active).to include(active_offer)
      expect(Offer.active).not_to include(inactive_offer)
    end
  end

  describe '#discount' do
    it 'raises NotImplementedError for base class' do
      offer = Offer.new
      items = [build(:product, :r01)]

      expect { offer.discount(items) }.to raise_error(NotImplementedError)
    end
  end

  describe 'factory traits' do
    it 'creates bulk percentage discount with correct attributes' do
      offer = create(:bulk_percentage_discount)
      expect(offer).to be_a(Offer::BulkPercentageDiscount)
      expect(offer.target_code).to eq('G01')
      expect(offer.percentage).to eq(10)
      expect(offer.min_qty).to eq(3)
      expect(offer.active).to be true
    end

    it 'creates buy one second half price with correct attributes' do
      offer = create(:buy_one_second_half_price)
      expect(offer).to be_a(Offer::BuyOneSecondHalfPrice)
      expect(offer.target_code).to eq('R01')
      expect(offer.active).to be true
    end
  end
end
