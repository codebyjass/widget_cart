Product.upsert_all(
  [
    { code: 'R01', name: 'Red Widget', price_cents: 32_95, stock: 20 },
    { code: 'G01', name: 'Green Widget', price_cents: 24_95, stock: 15 },
    { code: 'B01', name: 'Blue Widget', price_cents: 7_95, stock: 50 }
  ],
  unique_by: :code
)

DeliveryRule.upsert_all(
  [
    { threshold_cents: 0, fee_cents: 4_95 },
    { threshold_cents: 50_00, fee_cents: 2_95 },
    { threshold_cents: 90_00, fee_cents: 0 }
  ]
)

Offer::BuyOneSecondHalfPrice.find_or_create_by!(
  name: 'R01 second half price',
  target_code: 'R01',
  active: true
)

Offer::BulkPercentageDiscount.find_or_create_by!(
  name: 'G01 10 % off on 3+',
  target_code: 'G01',
  percentage: 10,
  min_qty: 3,
  active: true
)