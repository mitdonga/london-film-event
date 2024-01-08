require 'rails_helper'

RSpec.describe BxBlockProfile::ProfilesController, type: :controller do

  before do
    @company = FactoryBot.create(:company)
    @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
    @psw = @client_admin.generate_password
    @token = BuilderJsonWebToken.encode(@client_admin.id)
    @client_user = FactoryBot.create(:user_account, client_admin_id: @client_admin.id, company_id: @company.id)
    @client_token = BuilderJsonWebToken.encode(@client_user.id)
  end

  describe 'PUT #update' do
    context 'with valid parameters' do
      payload = {
      first_name: "test first name",
      last_name: "test last name"
      }

      it 'updates user profile' do
        put "update", params: {
            token: @client_token,
            account: payload,
            controller: "bx_block_profile/profiles",
            action: "update",
            id: @client_user.id,
            profile: { account: payload }
        }
        
        updated_profile = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(updated_profile["data"]["attributes"]["first_name"]).to eq(payload[:first_name])        
      end
    end

    context 'with invalid email' do
      payload = {
        first_name: "test first name",
        email: "test@test.com"
        }
  
      it 'returns errors in JSON' do
        put "update", params: 
        { token: @client_token,
          account: payload,
          controller: "bx_block_profile/profiles",
          action: "update",
          id: @client_user.id,
          profile: { account: payload } 
        }

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to eq(["You've entered an email from an external domain. Please confirm this is correct before saving."]
        )
      end
    end
  end
end
