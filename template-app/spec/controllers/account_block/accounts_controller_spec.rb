require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

RSpec.describe AccountBlock::AccountsController, type: :controller do

  before do 
    @psw = "@123456Builder"
    @company = FactoryBot.create(:company)
    @client_admin = FactoryBot.create(:client_admin, company_id: @company.id, password: @psw)
    @token = BuilderJsonWebToken.encode(@client_admin.id)
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

 

end