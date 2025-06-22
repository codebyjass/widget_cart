class DeliveryRule < ApplicationRecord
  monetize :threshold_cents
  monetize :fee_cents

  validates :threshold_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :fee_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :ordered_by_threshold, -> { order(:threshold_cents) }

  def applies_to?(amount)
    amount.cents >= threshold_cents
  end
end
