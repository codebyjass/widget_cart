class Offer::BuyOneSecondHalfPrice < Offer
  validates :target_code, presence: true

  def discount(items)
    return Money.zero if items.nil? || items.empty?
    
    matches = items.select { |p| p.code == target_code }
    pairs = matches.count / 2
    return Money.zero if pairs.zero?

    matches.first.price * 0.5 * pairs
  end
end
