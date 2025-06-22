# 10 % off when you buy >= min_qty
class Offer::BulkPercentageDiscount < Offer
  validates :target_code, :percentage, :min_qty, presence: true

  def discount(items)
    return Money.zero if items.nil? || items.empty?
    
    matches = items.select { |p| p.code == target_code }
    return Money.zero if matches.count < min_qty

    pct = percentage.to_d / 100
    matches.sum(&:price) * pct
  end
end
