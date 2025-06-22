class Basket
  def initialize(items:, delivery_rules:, offers: [])
    self.items = items || []
    self.delivery_rules = delivery_rules.sort_by(&:threshold_cents)
    self.offers = offers
  end

  def total_money
    subtotal = items.sum(&:price)
    discount = offers.sum { |o| o.discount(items) }
    after_discount = subtotal - discount
    after_discount + delivery_fee_for(after_discount)
  end

  def formatted_total(**opts)
    total_money.format(**{ symbol: "$", thousands_separator: ",", decimal_mark: "." }.merge(opts))
  end

  private

  attr_accessor :delivery_rules, :offers, :items

  def delivery_fee_for(amount)
    amount_cents = amount.respond_to?(:cents) ? amount.cents : amount
    rule = delivery_rules.reverse.find { |r| amount_cents >= r.threshold_cents }
    return rule.fee if rule

    Money.zero
  end
end
