module BxBlockDownloadoptions
  class ApplicationController < BuilderBase::ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation

    before_action :validate_json_web_token

    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    private

    def not_found
      render json: { 'errors' => ['Account not found'] }, status: :not_found
    end

    def current_user
      AccountBlock::Account.find(@token.id) if @token.present?
    end

    def format_activerecord_errors(errors)
      result = []
      errors.each do |attribute, error|
        result << { attribute => error }
      end
      result
    end
  end
end 
