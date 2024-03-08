module BxBlockMultilevelapproval
  class ApplicationController < BuilderBase::ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation

    before_action :current_user

    before_action :validate_json_web_token

    rescue_from ActiveRecord::RecordNotFound, :with => :not_found

    private

    def current_user
      @current_user ||= AccountBlock::Account.find(@token.id) if @token.present?
    end
  end
end
