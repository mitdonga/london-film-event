require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

RSpec.describe AccountBlock::AccountsController, type: :controller do

  before do 
    @company = FactoryBot.create(:company)
    @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
    @psw = @client_admin.generate_password
    @token = BuilderJsonWebToken.encode(@client_admin.id)
    
    @client_user = FactoryBot.create(:user_account, client_admin_id: @client_admin.id, company_id: @company.id)
    @user_token = BuilderJsonWebToken.encode(@client_user.id)
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

end