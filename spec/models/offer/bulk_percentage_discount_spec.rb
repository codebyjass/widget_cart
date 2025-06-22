require 'rails_helper'

RSpec.describe Offer::BulkPercentageDiscount, type: :model do
  describe 'validations' do
    subject { build(:bulk_percentage_discount) }

    it { is_expected.to validate_presence_of(:target_code) }
    it { is_expected.to validate_presence_of(:percentage) }
    it { is_expected.to validate_presence_of(:min_qty) }
  end

  describe '#discount' do
    let(:offer) { create(:bulk_percentage_discount, target_code: 'G01', percentage: 10, min_qty: 3) }
    let(:green_widget) { create(:product, :g01) }
    let(:red_widget) { create(:product, :r01) }

    context 'when quantity is below minimum' do
      it 'returns zero discount for 1 item' do
        items = [green_widget]
        expect(offer.discount(items)).to eq(Money.zero)
      end

      it 'returns zero discount for 2 items' do
        items = [green_widget, green_widget]
        expect(offer.discount(items)).to eq(Money.zero)
      end
    end

    context 'when quantity meets minimum' do
      it 'applies discount for exactly 3 items' do
        items = [green_widget, green_widget, green_widget]
        expected_discount = green_widget.price * 3 * 0.10
        expect(offer.discount(items)).to eq(expected_discount)
      end

      it 'applies discount for more than 3 items' do
        items = [green_widget, green_widget, green_widget, green_widget]
        expected_discount = green_widget.price * 4 * 0.10
        expect(offer.discount(items)).to eq(expected_discount)
      end
    end

    context 'with mixed products' do
      it 'only discounts matching products' do
        items = [green_widget, red_widget, green_widget, green_widget]
        expected_discount = green_widget.price * 3 * 0.10
        expect(offer.discount(items)).to eq(expected_discount)
      end

      it 'ignores non-matching products' do
        items = [red_widget, red_widget, red_widget]
        expect(offer.discount(items)).to eq(Money.zero)
      end
    end

    context 'with different percentage' do
      let(:offer) { create(:bulk_percentage_discount, target_code: 'G01', percentage: 20, min_qty: 2) }

      it 'applies correct percentage' do
        items = [green_widget, green_widget]
        expected_discount = green_widget.price * 2 * 0.20
        expect(offer.discount(items)).to eq(expected_discount)
      end
    end

    context 'with different minimum quantity' do
      let(:offer) { create(:bulk_percentage_discount, target_code: 'G01', percentage: 15, min_qty: 5) }

      it 'requires correct minimum quantity' do
        items = [green_widget] * 4
        expect(offer.discount(items)).to eq(Money.zero)

        items = [green_widget] * 5
        expected_discount = green_widget.price * 5 * 0.15
        expect(offer.discount(items)).to eq(expected_discount)
      end
    end
  end

  describe 'edge cases' do
    let(:offer) { create(:bulk_percentage_discount, target_code: 'G01', percentage: 10, min_qty: 3) }
    let(:green_widget) { create(:product, :g01) }

    it 'handles empty items array' do
      expect(offer.discount([])).to eq(Money.zero)
    end

    it 'handles nil items' do
      expect(offer.discount(nil)).to eq(Money.zero)
    end

    it 'handles large quantities' do
      items = [green_widget] * 100
      expected_discount = green_widget.price * 100 * 0.10
      expect(offer.discount(items)).to eq(expected_discount)
    end

    it 'handles decimal percentages' do
      offer = create(:bulk_percentage_discount, target_code: 'G01', percentage: 12.5, min_qty: 2)
      items = [green_widget, green_widget]
      expected_discount = green_widget.price * 2 * 0.125
      expect(offer.discount(items)).to eq(expected_discount)
    end
  end
end 