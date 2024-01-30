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
  
  describe 'GET #show' do
    it 'returns a successful response' do
      get :show, params: {  token: @client_token, id: @client_user.id }
      expect(response).to have_http_status(:ok)
    end

    it 'it gives error' do
      get :show, params: { id: @client_user.id }
      
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(400)
    end
  end

  describe 'PUT #update_profile' do
    context 'with valid parameters' do
      payload = {
      first_name: "test first name",
      last_name: "test last name",
      }

      it 'updates user profile' do
        put "update_profile", params: {
            token: @client_token,
            account: {
              first_name: "test first name",
              last_name: "test last name",
              email: @client_user.email
              },
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
        put "update_profile", params: 
        { token: @client_token,
          account: payload,
          controller: "bx_block_profile/profiles",
          action: "update",
          id: @client_user.id,
          profile: { account: payload } 
        }

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to eq("You've entered an email from an external domain. Please confirm this is correct before saving.")
      end
    end
  end

  describe 'PUT#popup_confirmation' do
    payload = {
      first_name: "new name",
      full_phone_number: ''
    }
    
    it 'updates the user account' do
      put :popup_confirmation, params: { token: @client_token,id: @client_user.id, email: 'test@test.com', first_name: @client_user.first_name, account: payload }     
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json_response["data"]["attributes"]["first_name"]).to eq(payload[:first_name])
      expect(json_response["data"]["attributes"]["email"]).to eq(@client_user.email)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.from).to include(@client_user.email)
    end

    it "updates the user account" do
      put :popup_confirmation, params: { id: @client_user.id, email: 'test@test.com', first_name: 'new name', account: payload }     
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(400)
    end
  end
end
