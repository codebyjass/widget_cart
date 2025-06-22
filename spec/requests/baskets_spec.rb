# spec/requests/baskets_spec.rb
require 'rails_helper'

RSpec.describe 'Baskets', type: :request do
  let!(:red_widget) { create(:product, :r01) }
  let!(:green_widget) { create(:product, :g01) }
  let!(:blue_widget) { create(:product, :b01) }
  let!(:delivery_rule) { create(:delivery_rule, :express_delivery) }
  let!(:standard_delivery) { create(:delivery_rule, :standard_delivery) }
  let!(:free_delivery) { create(:delivery_rule, :free_delivery) }
  let!(:offer) { create(:buy_one_second_half_price) }
  let!(:offer2) { create(:bulk_percentage_discount) }

  def parsed_json
    JSON.parse(response.body)
  end

  describe 'POST /api/v1/baskets' do
    context 'successful requests' do
      it 'calculates basket total for valid items' do
        post '/api/v1/baskets', params: { items: ['R01', 'G01', 'B01'] }

        expect(response).to have_http_status(:ok)
        expect(parsed_json['total']).to eq('$68.80')
      end

      it 'applies business rules correctly' do
        #  B01', 'G01' => $37.85
        post '/api/v1/baskets', params: { items: ['B01', 'G01'] }
        expect(response).to have_http_status(:ok)
        expect(parsed_json['total']).to eq('$37.85')

        # R01, R01 => $54.37
        post '/api/v1/baskets', params: { items: ['R01', 'R01'] }
        expect(response).to have_http_status(:ok)
        expect(parsed_json['total']).to eq('$54.37')

        # R01, G01 => $60.85
        post '/api/v1/baskets', params: { items: ['R01', 'G01'] }
        expect(response).to have_http_status(:ok)
        expect(parsed_json['total']).to eq('$60.85')

        # B01, B01, R01, R01, R01 => $103.22
        post '/api/v1/baskets', params: { items: ['B01', 'B01', 'R01', 'R01', 'R01'] }
        expect(response).to have_http_status(:ok)
        expect(parsed_json['total']).to eq('$98.27')
      end
    end

    context 'error handling' do
      it 'returns 400 for missing items parameter' do
        post '/api/v1/baskets', params: {}
        expect(response).to have_http_status(:bad_request)
        expect(parsed_json['errors']).to include("param is missing or the value is empty: items")
      end

      it 'returns 422 for empty items array' do
        post '/api/v1/baskets', params: { items: [] }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_json['errors']).to include('Items is empty')
      end

      it 'returns 422 for unknown product codes' do
        post '/api/v1/baskets', params: { items: ['INVALID'] }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_json['errors']).to include('Unknown product code(s): INVALID')
      end

      it 'returns 422 for out of stock items' do
        red_widget.update!(stock: 0)

        post '/api/v1/baskets', params: { items: ['R01'] }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_json['errors']).to include('Only 0 of R01 in stock; requested 1')
      end

      it 'returns 422 for invalid item format' do
        post '/api/v1/baskets', params: { items: 'invalid' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_json['errors']).to include('Unknown product code(s): invalid')
      end
    end

    context 'edge cases' do
      it 'handles case-sensitive product codes' do
        post '/api/v1/baskets', params: { items: ['r01', 'g01'] }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_json['errors']).to include('Unknown product code(s): r01, g01')
      end

      it 'handles large quantities' do
        post '/api/v1/baskets', params: { items: ['B01'] * 10 }
        expect(response).to have_http_status(:ok)
        expect(parsed_json['total']).to match(/^\$\d+\.\d{2}$/)
      end
    end
  end
end
