require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

RSpec.describe AccountBlock::AccountsController, type: :controller do
  include_context "setup data"

  before do 
    @company = FactoryBot.create(:company)
    @company_2 = FactoryBot.create(:company)

    @account = FactoryBot.create(:account)
    @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
    @psw = @client_admin.generate_password
    @token = BuilderJsonWebToken.encode(@client_admin.id)
    
    @client_user = FactoryBot.create(:user_account, client_admin_id: @client_admin.id, company_id: @company.id)
    @user_token = BuilderJsonWebToken.encode(@client_user.id)

    @client_admin_2 = FactoryBot.create(:admin_account, company_id: @company_2.id)
    @client_user_2 = FactoryBot.create(:user_account, client_admin_id: @client_admin_2.id, company_id: @company_2.id)

  end

  describe '#change_email_address' do
    context 'when changing email address successfully' do
      it 'updates the email address and returns the modified account' do
        old_email = @client_admin.email
        new_email = 'new.email@example.com'

        put :change_email_address, params: { token: @token, email: new_email }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to include('data')
        expect(json['data']['attributes']['email']).to eq(new_email)

        updated_admin = AccountBlock::ClientAdmin.find(@client_admin.id)
        expect(updated_admin.email).to eq(new_email)
        expect(updated_admin.email).not_to eq(old_email)
      end
    end

    context 'when the new email is invalid' do
      it 'returns unprocessable entity response with an error message' do
        put :change_email_address, params: { token: @token, email: 'invalid.email.com' }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json).to include('errors')
        expect(json['errors']).to eq('Email invalid')
      end
    end

    context 'when the account update fails' do
      it 'returns an error response with an appropriate message' do
        existing_account = FactoryBot.create(:account, email: 'existing.email@example.com')

        put :change_email_address, params: { token: @token, email: existing_account.email }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to include('errors')
        expect(json['errors']).to eq('account user email id is not updated')
      end
    end
  end

  describe '#change_password' do
    before do
      @new_psw = "*123456Builder"
    end

    it "should raise invalid password error" do
      put "change_password", params: { token: @token, current_password: @psw, new_password: "123456", confirm_password: "987655" }
      data = JSON.parse(response.body)
      expect(response).to have_http_status(422)
      expect(data["error"]).to eq("Please enter valid password")
    end

    it "should raise invalid credentials" do
      put "change_password", params: { token: @token, current_password: "WrongPassword#1234", new_password: @new_psw, confirm_password: @new_psw }
      data = JSON.parse(response.body)
      expect(response).to have_http_status(422)
      expect(data["message"]).to eq("Oops, something went wrong!")
      expect(data["errors"][0]).to eq("Invalid credentials")
    end

    it "should update password" do
      put "change_password", params: { token: @token, current_password: @psw, new_password: @new_psw, confirm_password: @new_psw }
      data = JSON.parse(response.body)
      expect(response).to have_http_status(201)
      expect(data["message"]).to eq("Password updated")
    end
  end

  describe '#index' do
    context 'when accounts are created' do
      before do
        
        @company = FactoryBot.create(:company)
        @token = BuilderJsonWebToken.encode(@account.id)
      end
      
      it 'returns a successful response with accounts' do
        get :index, params: { token: @token }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']).not_to be_empty
      end
    end
  end
  
  describe '#specific_account' do
    context 'when account exists' do
      before do
        @company = FactoryBot.create(:company)
        @token = BuilderJsonWebToken.encode(@account.id)
      end


      it 'returns the specific account' do
        get :specific_account, params: { token: @token, client_admin: @account.id}
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']).not_to be_empty
      end
    end
  end
  
  describe '#update_for_notification' do
    it 'should update email_enable to false' do
      put :update_for_notification, params: { token: @token }
      expect(response).to have_http_status(:ok)
      expect(@client_admin.reload.email_enable).to be_falsey
      expect(response.body).to include('email is disabled')
    end
  end

  describe "#update" do
    let(:params) do {
      token: @token,
      account: { first_name: "Updated First Name", last_name: "Updated Last Name" }
    } end
    it "should update account" do
      put "update", params: params
      expect(response).to have_http_status(200)
    end

    let(:error_params) do {
      token: @token,
      account: { email: "invalid@email" }
    } end
    it "should raise error" do
      put "update", params: error_params
      expect(response).to have_http_status(422)
    end
  end

  describe "#add_client_user" do
    let(:user_params) do {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.first_name,
      email: Faker::Internet.email, 
      full_phone_number: Faker::Base.numerify("9194########"), 
      account_type: "venue", 
      company_id: @company.id
    } end

    it "should create new user" do
      post "add_client_user", params: { token: @token, account: user_params }
      expect(response).to have_http_status(:created)
      expect(response.body).to include("Client user created successfully")
    end

    it "should raise unauthorized error" do
      post "add_client_user", params: { token: @user_token, account: user_params }
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to include("You're unauthorized to perform this action")
      expect(response.body).to include("Only client admin can perform this action")
    end

    it "should raise error" do
      post "add_client_user", params: { token: @token, account: user_params.except(:email) }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Failed to create client user")
    end
  end

  describe "#update_client_user" do
    let(:user_params) do {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.first_name,
      full_phone_number: Faker::Base.numerify("9194########"), 
    } end

    it "should update client user" do
      put "update_client_user", params: { token: @token, client_user_id: @client_user.id, account: user_params }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("User successfully updated")
    end

    it "should raise error" do
      put "update_client_user", params: { token: @token, client_user_id: @client_user_2.id, account: user_params }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("User not present or you're not authorized to update this user")
    end
  end

  describe "#remove_user" do
    it "should delete client user" do
      delete "remove_user", params: { token: @token, user_id: @client_user.id }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Client user removed successfully")
    end

    it "should raise error" do
      delete "remove_user", params: { token: @token, user_id: @client_user_2.id }
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to include("User not present or you're not authorized to delete this user")
    end
  end

  describe "#send_account_activation_email" do
    it "should send email" do
      post "send_account_activation_email", params: { token: @token, user_id: @client_user.id }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Success")
    end

    it "should raise error" do
      post "send_account_activation_email", params: { token: @token, user_id: @client_user_2.id }
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to include("User not present or you're not authorized")
    end
  end

  describe "#reset_password_email" do
    it "should raise invalid email" do
      put "reset_password_email", params: { email: "invalid.email.com" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Invalid Email")
    end

    it "should raise account not found" do
      put "reset_password_email", params: { email: "invalid.account@gmail.com" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Account not found")
    end

    it "should succeed" do
      put "reset_password_email", params: { email: @client_user.email }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Password reset link has been sent. Kindly check your email inbox for further instructions")
    end
  end

  describe "#update_email_enable_disable" do
    context 'update_disable_email' do
      before do
        @company = FactoryBot.create(:company)
        @client_admin = FactoryBot.create(:admin_account,email_enable: false, company_id: @company.id)
        @client_token = BuilderJsonWebToken.encode(@client_admin.id)
      end

      it "should update with enable if email is disabled" do
        put "update_for_notification", params: { token: @client_token }
        response_data = JSON.parse(response.body)
        expect(response).to have_http_status(200)
        expect(response_data["message"]).to eq("email is enabled")
      end
    end

    context 'update_disable_email' do
      before do
        @new_company = FactoryBot.create(:company)
        @new_client_admin = FactoryBot.create(:admin_account,email_enable: true, company_id: @new_company.id)
        @new_client_token = BuilderJsonWebToken.encode(@new_client_admin.id)
      end

      it "should update with enable if email is disabled" do
        put "update_for_notification", params: { token: @new_client_token }
        response_data = JSON.parse(response.body)
        expect(response).to have_http_status(200)
        expect(response_data["message"]).to eq("email is disabled")
      end
    end
  end

  describe "#reset_password" do
    it "should succeed" do
      put "reset_password", params: { token: @token, password: "@!234232BuilderAi", confirm_password: "@!234232BuilderAi" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Password updated successfully")
    end

    it "should raise invalid password" do
      put "reset_password", params: { token: @token, password: "234232", confirm_password: "234232" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Please enter valid password")
    end

    it "should raise password mismatch" do
      put "reset_password", params: { token: @token, password: "234232Builder", confirm_password: "234232" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Password and confirm password doesn't match")
    end

    it "should raise invalid token" do
      put "reset_password", params: { token: "no token", password: "@!234232B", confirm_password: "@!234232B" }
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to include("Invalid token")
    end
  end

  describe "#match_company_domain" do
    it "should raise invalid email error" do
      get "match_company_domain", params: { token: @token, email: "randome@domain.de" }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "should return success response" do
      get "match_company_domain", params: { token: @token, email: "support#{@client_admin.company.email}" }
      expect(response).to have_http_status(:ok)
    end
  end
  
end