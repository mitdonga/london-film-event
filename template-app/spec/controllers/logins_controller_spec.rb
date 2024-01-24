require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

RSpec.describe BxBlockLogin::LoginsController, type: :controller do
  describe 'POST #create' do
    before do
        @company = FactoryBot.create(:company)
        @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
        byebug
        @client_admin.update!(password: 'qwe', password_confirmation: 'qwe')
    end
    context 'with valid account type' do
        let(:valid_params) do
            {
            data: {
                type: 'email_account',
                attributes: {
                    "email": @client_admin.email,
                    "password": "qwe"
                }
            }
            }
        end

      it 'creates a new account' do
        post :create, params: valid_params
        expect(response).to have_http_status(:success)
      end

    end

    context 'with invalid account type' do
      let(:invalid_params) do
        {
          data: {
            type: 'invalid_account',
            attributes: {
            }
          }
        }
      end

      it 'returns unprocessable entity status' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
        @company = FactoryBot.create(:company)
        @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
        @client_admin.update!(password: 'qwe', password_confirmation: 'qwe', last_visit_at: Time.now)
    end
    context 'with valid account type' do
      let!(:valid_params) do
        {
          data: {
            type: 'email_account',
                attributes: {
                    "email": @client_admin.email,
                    "password": "qwe"
                }
          }
        }
      end

      it 'destroys the specified account' do
        delete :destroy, params: valid_params
        expect(response).to have_http_status(:success)
      end

    end

    context 'with invalid account type' do
      let(:invalid_params) do
        {
          data: {
            type: 'invalid_account',
            attributes: {
            }
          }
        }
      end

      it 'returns unprocessable entity status' do
        delete :destroy, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

