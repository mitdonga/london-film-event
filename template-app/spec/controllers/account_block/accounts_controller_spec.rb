require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

RSpec.describe AccountBlock::AccountsController, type: :controller do

  before do 
    @company = FactoryBot.create(:company)
    @company_2 = FactoryBot.create(:company)

    @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
    @psw = @client_admin.generate_password
    @token = BuilderJsonWebToken.encode(@client_admin.id)
    
    @client_user = FactoryBot.create(:user_account, client_admin_id: @client_admin.id, company_id: @company.id)
    @user_token = BuilderJsonWebToken.encode(@client_user.id)

    @client_admin_2 = FactoryBot.create(:admin_account, company_id: @company_2.id)
    @client_user_2 = FactoryBot.create(:user_account, client_admin_id: @client_admin_2.id, company_id: @company_2.id)

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
      country_code: "44", 
      email: Faker::Internet.email, 
      phone_number: Faker::Base.numerify("54########"), 
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
      country_code: "44", 
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

end