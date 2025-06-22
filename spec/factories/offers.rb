FactoryBot.define do
  factory :bulk_percentage_discount, class: 'Offer::BulkPercentageDiscount' do
    active { true }
    type { 'Offer::BulkPercentageDiscount' }
    name { 'G01 10 % off on 3+' }
    target_code { 'G01' }
    percentage { 10 }
    min_qty { 3 }

    trait :inactive do
      active { false }
    end
  end

  factory :buy_one_second_half_price, class: 'Offer::BuyOneSecondHalfPrice' do
    active { true }
    type { 'Offer::BuyOneSecondHalfPrice' }
    name { 'R01 second half price' }
    target_code { 'R01' }
    percentage { nil }
    min_qty { nil }

    trait :inactive do
      active { false }
    end
  end
end
