class Api::V1::BasketsController < ApplicationController
  def create
    items = ItemsBuilder.new(raw_items: items_params).call
    basket = Basket.new(items: items, delivery_rules: DeliveryRule.all, offers: Offer.active)
    render json: { total: basket.formatted_total }
  end

  private

  def items_params
    params.require(:items)
  end
end
