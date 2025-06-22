FactoryBot.define do
  factory :product do
    sequence(:code) { |n| "PROD#{n}" }
    sequence(:name) { |n| "Product #{n}" }
    price_cents { 1000 }
    stock { 10 }

    trait :r01 do
      code { 'R01' }
      name { 'Red Widget' }
      price_cents { 3295 }
      stock { 20 }
    end

    trait :g01 do
      code { 'G01' }
      name { 'Green Widget' }
      price_cents { 2495 }
      stock { 15 }
    end

    trait :b01 do
      code { 'B01' }
      name { 'Blue Widget' }
      price_cents { 795 }
      stock { 50 }
    end
  end
end
