require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

RSpec.describe BxBlockNotifications::NotificationsController, type: :controller do
  describe 'GET #index' do
    context 'when notifications are present' do
      before do 
        @company = FactoryBot.create(:company) 
        @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
        @token = BuilderJsonWebToken.encode(@client_admin.id)
        @notification = FactoryBot.create(:notification, account_id: @client_admin.id)
      end

      it 'returns a successful response with a list of notification' do
        get "index", params: {token: @token}
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when notifications are not present' do
      before do 
        @company = FactoryBot.create(:company) 
        @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
        @token = BuilderJsonWebToken.encode(@client_admin.id)
      end
      it 'returns an unprocessable entity response with an error message' do
        get "index", params: {token: @token}
        json = JSON.parse(response.body)
        expect(json["errors"][0]["message"]).to eq("No notification found.")
      end
    end
  end
  
  describe 'GET #unreaded_notifications' do
    context 'when notifications are present we get a list of notifications' do
      before do 
        @company = FactoryBot.create(:company) 
        @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
        @token = BuilderJsonWebToken.encode(@client_admin.id)
        @notification = FactoryBot.create(:notification, account_id: @client_admin.id)
      end

      it 'returns a successful response with a list of top 5 notifications' do
        get "unreaded_notifications", params: {token: @token}
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when notifications are not present or readed' do
      before do 
        @company = FactoryBot.create(:company) 
        @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
        @token = BuilderJsonWebToken.encode(@client_admin.id)
      end
      it 'returns an unprocessable entity response and an error message' do
        get "unreaded_notifications", params: {token: @token}
        json = JSON.parse(response.body)
        expect(json["errors"][0]["message"]).to eq("No unreaded notifications.")
      end
    end
  end

  describe 'GET #show' do
    before do
      @company = FactoryBot.create(:company) 
      @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
      @token = BuilderJsonWebToken.encode(@client_admin.id)
      @notification = FactoryBot.create(:notification, account_id: @client_admin.id)
    end

    it 'returns a successful response with the serialized notification' do
      get :show, params: { id: @notification.id, token: @token }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('data')
      expect(JSON.parse(response.body)['meta']['message']).to eq('Success.')
    end
  end

  describe 'PATCH #update' do
    context 'when notifications are marked as read' do
      before do 
        @company = FactoryBot.create(:company) 
        @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
        @token = BuilderJsonWebToken.encode(@client_admin.id)
        @notification = FactoryBot.create(:notification, account_id: @client_admin.id)
      end

      it 'marks the notification as read' do
        patch :update, params: { id: @notification.id, token: @token }
        @notification.reload

        expect(response).to have_http_status(:ok)
        expect(@notification.reload.is_read).to eq(true)
        expect(@notification.read_at).to be_within(1.second).of(Time.now)
      end
    end   
  end

  describe 'NotificationsController' do
    context '#format_activerecord_errors' do  
      it 'handles empty errors hash' do
        expect(controller.send(:format_activerecord_errors, {})).to eq([])
      end
    end
  end
end