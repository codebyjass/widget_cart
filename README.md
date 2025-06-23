# Widget Cart API

A Ruby on Rails API for calculating shopping cart totals with support for product discounts and delivery rules.

## Features

- **Product Management**: Support for multiple products with stock tracking
- **Dynamic Pricing**: Configurable offers and discounts
- **Delivery Rules**: Tiered delivery fees based on order value
- **RESTful API**: Simple JSON API for basket calculations
- **Comprehensive Testing**: Full RSpec test coverage

## Business Logic

### Products
- **Red Widget (R01)**: $32.95 each
- **Green Widget (G01)**: $24.95 each  
- **Blue Widget (B01)**: $7.95 each

### Offers
- **R01 Second Half Price**: Buy one R01, get the second R01 at half price
- **G01 Bulk Discount**: 10% off when buying 3 or more G01 items

### Delivery Rules
- **$0 - $49.99**: $4.95 delivery fee
- **$50.00 - $89.99**: $2.95 delivery fee
- **$90.00+**: Free delivery

## Technology Stack

- **Ruby**: 3.4.1
- **Rails**: 7.2.2
- **Database**: PostgreSQL
- **Testing**: RSpec, FactoryBot
- **Money Handling**: money-rails gem
- **Containerization**: Docker

## Prerequisites

- Ruby 3.4.1
- PostgreSQL
- Docker (optional)

## Installation

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd widget_cart
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Start the server**
   ```bash
   rails server
   ```

The API will be available at `http://localhost:3000`

### Docker Setup

1. **Build the image**
   ```bash
   docker build -t widget-cart .
   ```

2. **Run the container**
   ```bash
   docker run -p 3000:3000 -e RAILS_MASTER_KEY=<your-master-key> widget-cart
   ```

## API Usage

### Calculate Basket Total

**Endpoint**: `POST /api/v1/baskets`

**Request Format**:
```json
{
  "items": ["R01", "G01", "B01", "R01"]
}
```

**Response Format**:
```json
{
  "total": "$98.27"
}
```

### Example Requests

#### Single Item
```bash
curl -X POST http://localhost:3000/api/v1/baskets \
  -H "Content-Type: application/json" \
  -d '{"items": ["R01"]}'
```
Response: `{"total": "$37.90"}` (includes delivery fee)

#### Multiple Items with Discounts
```bash
curl -X POST http://localhost:3000/api/v1/baskets \
  -H "Content-Type: application/json" \
  -d '{"items": ["R01", "R01", "G01", "G01", "G01"]}'
```
Response: `{"total": "$98.27"}` (includes R01 half-price offer and G01 bulk discount)

#### Free Delivery Threshold
```bash
curl -X POST http://localhost:3000/api/v1/baskets \
  -H "Content-Type: application/json" \
  -d '{"items": ["R01", "R01", "G01", "G01", "G01", "B01", "B01", "B01"]}'
```
Response: `{"total": "$114.17"}` (free delivery due to $90+ total)

### Error Handling

The API returns appropriate HTTP status codes and error messages:

- **400 Bad Request**: Invalid request format
- **422 Unprocessable Entity**: Business logic errors (out of stock, unknown products, etc.)

**Error Response Format**:
```json
{
  "errors": ["Items is empty", "Unknown product code(s): INVALID"]
}
```

## Testing

### Run All Tests
```bash
bundle exec rspec
```

### Test Coverage

The test suite covers:
- **API Endpoints**: Request/response handling, error cases
- **Services**: Basket calculation, items building
- **Models**: Validations, business logic, offer calculations
- **Factories**: Test data generation with seed-based traits

## Project Structure

```
app/
├── controllers/
│   ├── api/v1/
│   │   └── baskets_controller.rb    # Main API endpoint
│   └── concerns/
│       └── error_handlers.rb        # Error handling
├── models/
│   ├── product.rb                   # Product management
│   ├── delivery_rule.rb            # Delivery fee rules
│   ├── offer.rb                    # Base offer class
│   └── offer/                      # Offer implementations
│       ├── bulk_percentage_discount.rb
│       └── buy_one_second_half_price.rb
└── services/
    ├── basket.rb                   # Main calculation service
    └── items_builder.rb            # Input validation and processing

spec/
├── factories/                      # Test data factories
├── requests/                       # API endpoint tests
├── services/                       # Service layer tests
└── models/                         # Model tests
```
