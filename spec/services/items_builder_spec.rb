require 'rails_helper'

RSpec.describe ItemsBuilder do
  let!(:product_g01) { create(:product, :g01) }
  let!(:product_b01) { create(:product, :b01) }
  let!(:product_r01) { create(:product, :r01) }

  describe '#call' do
    context 'with valid items' do
      it 'builds items from product codes' do
        items = ['G01', 'B01', 'G01']
        result = described_class.new(raw_items: items).call

        expect(result).to match_array([product_g01, product_b01, product_g01])
      end

      it 'handles empty strings' do
        items = ['G01', '', 'B01']
        result = described_class.new(raw_items: items).call

        expect(result).to match_array([product_g01, product_b01])
      end

      it 'handles nil values' do
        items = ['G01', nil, 'B01']
        result = described_class.new(raw_items: items).call

        expect(result).to match_array([product_g01, product_b01])
      end
    end

    context 'with invalid items' do
      it 'raises InvalidPayload for non-string/symbol items' do
        items = ['G01', 123, 'B01']
        
        expect { described_class.new(raw_items: items).call }.to raise_error(ItemsBuilder::InvalidPayload, /Unknown product code\(s\): 123/)
      end

      it 'raises InvalidPayload for unknown product codes' do
        items = ['G01', 'UNKNOWN', 'B01']
        
        expect { described_class.new(raw_items: items).call }.to raise_error(ItemsBuilder::InvalidPayload, /Unknown product code\(s\): UNKNOWN/)
      end
    end

    context 'when an item is out of stock' do
      it 'raises OutOfStock' do
        items = Array.new(21, 'R01') # R01 has 20 in stock
        builder = described_class.new(raw_items: items)
        
        expect { builder.call }.to raise_error(ItemsBuilder::OutOfStock, /Only 20 of R01 in stock; requested 21/)
      end
    end

    context 'with empty array' do
      it 'raises InvalidPayload for empty items' do
        expect { described_class.new(raw_items: []).call }.to raise_error(ItemsBuilder::InvalidPayload, /Items is empty/)
      end

      it 'raises InvalidPayload for nil input' do
        expect { described_class.new(raw_items: nil).call }.to raise_error(ItemsBuilder::InvalidPayload, /Items is empty/)
      end
    end
  end
end
