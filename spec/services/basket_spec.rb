# spec/services/basket_spec.rb
require 'rails_helper'

RSpec.describe Basket do
  let!(:red_widget)   { create(:product, :r01) }
  let!(:green_widget) { create(:product, :g01) }
  let!(:blue_widget)  { create(:product, :b01) }
  let!(:delivery_rules) { [create(:delivery_rule, :express_delivery)] }

  describe 'specific business cases' do
    let!(:r01_offer) { create(:buy_one_second_half_price) }
    let!(:g01_offer) { create(:bulk_percentage_discount) }
    let!(:all_delivery_rules) do
      [
        create(:delivery_rule, :express_delivery),   # $0-49.99: $4.95
        create(:delivery_rule, :standard_delivery),  # $50-89.99: $2.95
        create(:delivery_rule, :free_delivery)       # $90+: $0
      ]
    end

    it 'B01, G01 => $37.85' do
      basket = described_class.new(
        items: [blue_widget, green_widget],
        delivery_rules: delivery_rules
      )
      expect(basket.formatted_total).to eq('$37.85')
    end

    it 'R01, R01 => $54.37' do
      basket = described_class.new(
        items: [red_widget, red_widget],
        delivery_rules: delivery_rules,
        offers: [r01_offer]
      )
      expect(basket.formatted_total).to eq('$54.37')
    end

    it 'R01, G01 => $60.85' do
      basket = described_class.new(
        items: [red_widget, green_widget],
        delivery_rules: all_delivery_rules
      )
      expect(basket.formatted_total).to eq('$60.85')
    end

    it 'B01, B01, R01, R01, R01 => $103.22' do
      basket = described_class.new(
        items: [blue_widget, blue_widget, red_widget, red_widget, red_widget],
        delivery_rules: delivery_rules,
        offers: [r01_offer]
      )
      expect(basket.formatted_total).to eq('$103.22')
    end
  end

  describe 'business scenarios' do
    it 'calculates basic basket with delivery fee' do
      basket = described_class.new(
        items: [blue_widget, green_widget],
        delivery_rules: delivery_rules
      )
      expect(basket.formatted_total).to eq('$37.85')
    end

    it 'applies R01 second half price offer' do
      offer = create(:buy_one_second_half_price)
      basket = described_class.new(
        items: [red_widget, red_widget],
        delivery_rules: delivery_rules,
        offers: [offer]
      )
      expect(basket.formatted_total).to eq('$54.37')
    end

    it 'applies G01 bulk discount for 3+ items' do
      offer = create(:bulk_percentage_discount)
      basket = described_class.new(
        items: [green_widget, green_widget, green_widget],
        delivery_rules: delivery_rules,
        offers: [offer]
      )
      expect(basket.formatted_total).to eq('$72.31')
    end

    it 'applies both offers together' do
      offers = [create(:buy_one_second_half_price), create(:bulk_percentage_discount)]
      basket = described_class.new(
        items: [red_widget, red_widget, green_widget, green_widget, green_widget],
        delivery_rules: delivery_rules,
        offers: offers
      )
      expect(basket.formatted_total).to eq('$121.73')
    end
  end

  describe 'delivery rules' do
    let!(:all_delivery_rules) do
      [
        create(:delivery_rule, :express_delivery),   # $0-49.99: $4.95
        create(:delivery_rule, :standard_delivery),  # $50-89.99: $2.95
        create(:delivery_rule, :free_delivery)       # $90+: $0
      ]
    end

    it 'applies standard delivery for medium value orders' do
      basket = described_class.new(
        items: [red_widget, green_widget],
        delivery_rules: all_delivery_rules
      )
      # $32.95 + $24.95 = $57.90, should get standard delivery ($2.95)
      expect(basket.formatted_total).to eq('$60.85')
    end

    it 'applies free delivery for high value orders' do
      basket = described_class.new(
        items: [red_widget, red_widget, green_widget, green_widget, green_widget],
        delivery_rules: all_delivery_rules
      )
      # Should be over $90, so free delivery
      expect(basket.total_money).to be > Money.new(9000)
    end
  end

  describe 'edge cases' do
    it 'handles empty basket with delivery fee' do
      basket = described_class.new(items: [], delivery_rules: delivery_rules)
      expect(basket.formatted_total).to eq('$4.95')
    end

    it 'handles large quantities efficiently' do
      basket = described_class.new(
        items: [blue_widget] * 50,
        delivery_rules: delivery_rules
      )
      expect(basket.formatted_total).to match(/^\$\d+\.\d{2}$/)
    end
  end

  describe '#formatted_total' do
    it 'returns properly formatted currency string' do
      basket = described_class.new(
        items: [red_widget],
        delivery_rules: delivery_rules
      )
      expect(basket.formatted_total).to match(/^\$\d+\.\d{2}$/)
    end
  end
end
