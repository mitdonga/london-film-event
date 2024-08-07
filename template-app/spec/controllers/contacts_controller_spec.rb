require 'rails_helper'

RSpec.describe BxBlockContactUs::ContactsController, type: :controller do

  before do
    @company = FactoryBot.create(:company)
    @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
    @psw = @client_admin.generate_password
    @token = BuilderJsonWebToken.encode(@client_admin.id)
    @client_user = FactoryBot.create(:user_account, client_admin_id: @client_admin.id, company_id: @company.id)
    @client_token = BuilderJsonWebToken.encode(@client_user.id)
    @contact = FactoryBot.create(:contact, account_id: @client_user.id,email: @client_user.email)
  end

  describe '#create_notification_for_contact_creation' do
    it 'creates a new notification when a contact is created' do
      contact = FactoryBot.create(:contact, account_id: @client_user.id, email: @client_user.email)

      expect {
        controller.send(:create_notification_for_contact_creation, contact)
      }.to change(BxBlockNotifications::Notification, :count).by(1)

      notification = BxBlockNotifications::Notification.last
      expect(notification.headings).to eq('New Contact Created')
      expect(notification.contents).to eq("A new contact with id #{contact.id} has been created.")
      expect(notification.account).to eq(@client_user)
    end
  end

  describe 'POST #create' do
    
    context 'with valid parameters' do
      it 'creates a new contact' do
        post :create, params: { token: @client_token,email: @client_user.email, first_name: "test", last_name: "testing"}
        expect(response).to have_http_status(:created)
      end

      it 'returns the created contact as JSON' do
        post :create, params: { token: @client_token,email: @client_user.email, first_name: "john", last_name: "doe" }
        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['attributes']['first_name']).not_to be_empty
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
            first_name: '',
            last_name: '',
            email: '',
            country_code: '',
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
