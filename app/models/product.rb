class Product < ApplicationRecord
  monetize :price_cents

  validates :code, :name, :price_cents, :stock, presence: true
  validates :code, uniqueness: true
  validates :price_cents, :stock, numericality: { greater_than_or_equal_to: 0 }

  scope :in_stock, -> { where('stock > 0') }

  def in_stock?
    stock > 0
  end

  def available_quantity(requested_qty)
    [stock, requested_qty].min
  end
end
