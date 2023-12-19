require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

include Warden::Test::Helpers

RSpec.describe Admin::ContactRequestsController, type: :controller do
  render_views
  before(:each) do
    @admin = AdminUser.create!(email: 'test123@example.com', password: 'password', password_confirmation: 'password')
    @admin.save
    @account = FactoryBot.create(:account)
    @contact = FactoryBot.create(:contact,phone_number: 9993334442,account_id: @account.id)
    sign_in @admin
  end
  
  describe "Post#new" do
    let!(:params) do {
        first_name: "Builder",
        las_name: "AI",
        email: "xyz@gmail.com",
        phone_number: Faker::Base.numerify('+918#########')
      }
    end
    it "create company" do
      post :new, params: params
      expect(response).to have_http_status(200)
    end
  end

  describe "Get#index" do
    it "show all contact requests" do
      get :index
      expect(response).to have_http_status(200)
    end
  end

  describe "Put#edit" do
    let(:params) do {
      "first_name" => "John"
    }end
    it "edit company" do
        put :update, params: {id: @contact.id, contact: params}
        expect(response).to have_http_status(302)
    end
  end
end