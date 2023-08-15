module BxBlockOrderReservations
  class ApplicationController < BuilderBase::ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation

    before_action :validate_json_web_token

    rescue_from ActiveRecord::RecordNotFound, :with => :not_found

    def find_current_user
      return render json: {error: "token not found"}, status: 401 if !request.headers[:token].present?
      return unless @token
      @current_user ||= AccountBlock::Account.find(@token.id)
    end

    private

    def not_found
      render :json => {'errors' => ['Record not found']}, :status => :not_found
    end
  end
end
