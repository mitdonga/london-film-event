module BxBlockLogin
  class LoginsController < ApplicationController
    def create
      case params[:data][:type] #### rescue invalid API format
      when 'sms_account', 'email_account', 'social_account'
        account = OpenStruct.new(jsonapi_deserialize(params))
        account.type = params[:data][:type]

        output = AccountAdapter.new

        output.on(:account_not_found) do |account|
          render json: {
            errors: [{
              failed_login: 'Account not found',
            }],
          }, status: :unprocessable_entity
        end

        output.on(:account_not_activated) do |account|
          render json: {
            errors: [{
              failed_login: 'Account not activated',
            }],
          }, status: :unprocessable_entity
        end

        output.on(:failed_login) do |account|
          render json: {
            errors: [{
              failed_login: 'Login failed, please enter correct password',
            }],
          }, status: :unauthorized
        end

        output.on(:successful_login) do |account, token, refresh_token|
          render json: {meta: {
            token: token,
            refresh_token: refresh_token,
            id: account.id,
            account: AccountBlock::AccountSerializer.new(account)
          }}
        end

        output.login_account(account)
      else
        render json: {
          errors: [{
            account: 'Invalid Account Type',
          }],
        }, status: :unprocessable_entity
      end
    end
  end
end
