class ItemsBuilder
  InvalidPayload = Class.new(StandardError)
  OutOfStock = Class.new(StandardError)

  def initialize(raw_items:)
    @raw_items = Array(raw_items).select(&:present?).map(&:to_s)
  end

  def call
    raise InvalidPayload.new("Items is empty") if @raw_items.empty?

    codes_with_qty = @raw_items.tally
    products = Product.where(code: codes_with_qty.keys).index_by(&:code)

    missing = codes_with_qty.keys - products.keys
    raise InvalidPayload.new("Unknown product code(s): #{missing.join(', ')}") if missing.any?

    build_array_and_check_stock(codes_with_qty, products)
  end

  private

  def build_array_and_check_stock(codes_with_qty, products)
    codes_with_qty.flat_map do |code, qty|
      product = products.fetch(code)

      if qty > product.stock
        raise OutOfStock, "Only #{product.stock} of #{code} in stock; requested #{qty}"
      end

      Array.new(qty, product)
    end
  end
end
