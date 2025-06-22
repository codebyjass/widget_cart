require 'rails_helper'

RSpec.describe Offer::BuyOneSecondHalfPrice, type: :model do
  describe 'validations' do
    subject { build(:buy_one_second_half_price) }

    it { is_expected.to validate_presence_of(:target_code) }
  end

  describe '#discount' do
    let(:offer) { create(:buy_one_second_half_price) }
    let(:red_widget) { create(:product, :r01) }
    let(:green_widget) { create(:product, :g01) }

    context 'with R01 items' do
      it 'returns zero discount for single item' do
        items = [red_widget]
        expect(offer.discount(items)).to eq(Money.zero)
      end

      it 'returns 50% discount for second item' do
        items = [red_widget, red_widget]
        expected_discount = red_widget.price * 0.5
        expect(offer.discount(items)).to eq(expected_discount)
      end

      it 'returns 50% discount for third item' do
        items = [red_widget, red_widget, red_widget]
        expected_discount = red_widget.price * 0.5
        expect(offer.discount(items)).to eq(expected_discount)
      end

      it 'returns 100% discount for fourth item' do
        items = [red_widget, red_widget, red_widget, red_widget]
        expected_discount = red_widget.price * 0.5 * 2
        expect(offer.discount(items)).to eq(expected_discount)
      end

      it 'returns 100% discount for fifth item' do
        items = [red_widget, red_widget, red_widget, red_widget, red_widget]
        expected_discount = red_widget.price * 0.5 * 2
        expect(offer.discount(items)).to eq(expected_discount)
      end

      it 'returns 150% discount for sixth item' do
        items = [red_widget, red_widget, red_widget, red_widget, red_widget, red_widget]
        expected_discount = red_widget.price * 0.5 * 3
        expect(offer.discount(items)).to eq(expected_discount)
      end
    end

    context 'with mixed items' do
      it 'applies discount only to R01 items' do
        items = [red_widget, green_widget, red_widget]
        expected_discount = red_widget.price * 0.5
        expect(offer.discount(items)).to eq(expected_discount)
      end

      it 'ignores non-R01 items' do
        items = [green_widget, green_widget]
        expect(offer.discount(items)).to eq(Money.zero)
      end

      it 'applies discount correctly with mixed items' do
        items = [red_widget, green_widget, red_widget, green_widget, red_widget]
        expected_discount = red_widget.price * 0.5
        expect(offer.discount(items)).to eq(expected_discount)
      end
    end

    context 'with different target codes' do
      it 'applies discount to correct target code' do
        offer = create(:buy_one_second_half_price, target_code: 'G01')
        items = [green_widget, green_widget]
        expected_discount = green_widget.price * 0.5
        expect(offer.discount(items)).to eq(expected_discount)
      end
    end
  end

  describe 'edge cases' do
    let(:offer) { create(:buy_one_second_half_price) }
    let(:red_widget) { create(:product, :r01) }

    it 'handles large quantities correctly' do
      items = [red_widget] * 100
      expected_discount = red_widget.price * 0.5 * 50 # 50 pairs
      expect(offer.discount(items)).to eq(expected_discount)
    end

    it 'handles odd quantities correctly' do
      items = [red_widget] * 7
      expected_discount = red_widget.price * 0.5 * 3 # 3 pairs, 1 single
      expect(offer.discount(items)).to eq(expected_discount)
    end

    it 'handles even quantities correctly' do
      items = [red_widget] * 8
      expected_discount = red_widget.price * 0.5 * 4 # 4 pairs
      expect(offer.discount(items)).to eq(expected_discount)
    end
  end

  describe 'pair counting logic' do
    let(:offer) { create(:buy_one_second_half_price) }
    let(:red_widget) { create(:product, :r01) }

    it 'counts pairs correctly' do
      expect(offer.discount([red_widget] * 1)).to eq(Money.zero)      # 0 pairs
      expect(offer.discount([red_widget] * 2)).to eq(red_widget.price * 0.5)  # 1 pair
      expect(offer.discount([red_widget] * 3)).to eq(red_widget.price * 0.5)  # 1 pair
      expect(offer.discount([red_widget] * 4)).to eq(red_widget.price * 0.5 * 2)  # 2 pairs
      expect(offer.discount([red_widget] * 5)).to eq(red_widget.price * 0.5 * 2)  # 2 pairs
      expect(offer.discount([red_widget] * 6)).to eq(red_widget.price * 0.5 * 3)  # 3 pairs
    end
  end
end 