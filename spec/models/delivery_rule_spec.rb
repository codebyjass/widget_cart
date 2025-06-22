require 'rails_helper'

RSpec.describe DeliveryRule do
  describe 'validations' do
    it { should validate_presence_of(:threshold_cents) }
    it { should validate_presence_of(:fee_cents) }
    it { should validate_numericality_of(:threshold_cents).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:fee_cents).is_greater_than_or_equal_to(0) }
  end

  describe 'monetization' do
    it 'handles money conversion correctly' do
      rule = build(:delivery_rule, threshold_cents: 5000, fee_cents: 295)
      expect(rule.threshold).to eq(Money.new(5000))
      expect(rule.fee).to eq(Money.new(295))
    end
  end

  describe 'scopes' do
    it 'orders by threshold ascending' do
      rule1 = create(:delivery_rule, threshold_cents: 5000)
      rule2 = create(:delivery_rule, threshold_cents: 0)
      rule3 = create(:delivery_rule, threshold_cents: 9000)

      expect(DeliveryRule.ordered_by_threshold).to eq([rule2, rule1, rule3])
    end
  end

  describe '#applies_to?' do
    let(:rule) { create(:delivery_rule, :standard_delivery) }

    it 'returns true when amount meets threshold' do
      expect(rule.applies_to?(Money.new(6000))).to be true
    end

    it 'returns false when amount is below threshold' do
      expect(rule.applies_to?(Money.new(4000))).to be false
    end

    it 'returns true when amount equals threshold' do
      expect(rule.applies_to?(Money.new(5000))).to be true
    end
  end
end
