module ErrorHandlers
  extend ActiveSupport::Concern

  included do
    rescue_from ItemsBuilder::InvalidPayload, with: :render_422
    rescue_from ItemsBuilder::OutOfStock, with: :render_422

    rescue_from ActiveRecord::RecordInvalid, with: :render_model_errors
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

    rescue_from ActionController::ParameterMissing, with: :render_bad_request

    rescue_from StandardError, with: :render_500 if Rails.env.production?
  end

  private

  def render_422(e)
    msgs = e.respond_to?(:messages) ? e.messages : e.message
    json_error msgs, :unprocessable_entity
  end

  def render_not_found(e) = json_error e.message, :not_found

  def render_bad_request(e) = json_error e.message, :bad_request

  def render_model_errors(e)
    json_error e.record.errors.full_messages, :unprocessable_entity
  end

  def render_500(e)
    logger.error e.full_message
    json_error "Internal server error", :internal_server_error
  end

  def json_error(msgs, status)
    render json: { errors: Array(msgs) }, status: status
  end
end
