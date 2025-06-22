FactoryBot.define do
  factory :delivery_rule do
    threshold_cents { 0 }
    fee_cents { 495 }

    trait :free_delivery do
      threshold_cents { 9000 } # $90.00
      fee_cents { 0 }
    end

    trait :standard_delivery do
      threshold_cents { 5000 } # $50.00
      fee_cents { 295 }
    end

    trait :express_delivery do
      threshold_cents { 0 } # $0.00
      fee_cents { 495 } # $4.95
    end
  end
end
