require 'rails_helper'

RSpec.describe BxBlockContactUs::ContactsController, type: :controller do

  before do
    @company = FactoryBot.create(:company)
    @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
    @psw = @client_admin.generate_password
    @token = BuilderJsonWebToken.encode(@client_admin.id)
    
    @client_user = FactoryBot.create(:user_account, client_admin_id: @client_admin.id, company_id: @company.id)
    @client_token = BuilderJsonWebToken.encode(@client_user.id)
  end

  describe 'POST #create' do
    let!(:valid_params) do
      {
        first_name: 'John',
        last_name: 'Doe',
        email: 'john.doe@example.com',
        phone_number: '1234567890',
        subject: 'Inquiry',
        details: 'Lorem ipsum'
        }
    end

    context 'with valid parameters' do
      it 'creates a new contact' do
        post :create, params: { token: @client_token, data: valid_params }
        expect(response).to have_http_status(:created)
      end

      it 'returns the created contact as JSON' do
        post :create, params: { token: @client_token, data: valid_params }
        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['attributes']['first_name']).to eq('John')
        expect(json_response['data']['attributes']['last_name']).to eq('Doe')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
            first_name: '',
            last_name: '',
            email: '',
            phone_number: '',
            subject: '',
            details: ''
        }
      end

      it 'does not create a new contact' do
        post :create, params: { token: @client_token, data: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns errors in JSON' do
        post :create, params: { token: @client_token, data: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to be_present
      end
    end
  end
end
