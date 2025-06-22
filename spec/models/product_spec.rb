require 'rails_helper'

RSpec.describe Product do
  describe 'validations' do
    subject { build(:product) }

    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:price_cents) }
    it { should validate_presence_of(:stock) }
    it { should validate_numericality_of(:price_cents).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:stock).is_greater_than_or_equal_to(0) }
    it { should validate_uniqueness_of(:code) }
  end

  describe 'monetization' do
    it 'handles money conversion correctly' do
      product = create(:product, price_cents: 3295)
      expect(product.price).to eq(Money.new(3295))
      expect(product.price.to_f).to eq(32.95)
    end
  end

  describe 'business logic' do
    let(:product) { build(:product, stock: 10) }

    describe '#in_stock?' do
      it 'returns true when stock is available' do
        expect(product.in_stock?).to be true
      end

      it 'returns false when out of stock' do
        product.stock = 0
        expect(product.in_stock?).to be false
      end
    end

    describe '#available_quantity' do
      it 'returns requested quantity when stock is sufficient' do
        expect(product.available_quantity(5)).to eq(5)
      end

      it 'returns available stock when requested exceeds stock' do
        expect(product.available_quantity(15)).to eq(10)
      end
    end
  end

  describe 'scopes' do
    let!(:in_stock_product) { create(:product, stock: 5) }
    let!(:out_of_stock_product) { create(:product, stock: 0) }

    describe '.in_stock' do
      it 'returns only products with available stock' do
        expect(Product.in_stock).to include(in_stock_product)
        expect(Product.in_stock).not_to include(out_of_stock_product)
      end
    end
  end

  describe 'edge cases' do
    it 'allows zero stock for out-of-stock products' do
      product = build(:product, stock: 0)
      expect(product).to be_valid
    end

    it 'prevents duplicate product codes' do
      create(:product, code: 'TEST')
      duplicate = build(:product, code: 'TEST')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:code]).to include('has already been taken')
    end
  end
end
