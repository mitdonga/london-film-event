require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

include Warden::Test::Helpers

RSpec.describe Admin::ClientAdminsController, type: :controller do
  render_views
  before(:each) do
    @admin = AdminUser.create!(email: 'test123@example.com', password: 'password', password_confirmation: 'password')
    @admin.save
    @company = FactoryBot.create(:company)
    @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)

    sign_in @admin
    redirect_to admin_lf_admins_path
    sleep 1
    redirect_to admin_client_admins_path
  end
  describe "Post#new" do
    let(:params) do {
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: Faker::Internet.email,
        password: Faker::Internet.password,
        country_code: "91",
        account_type: "venue",
        phone_number: Faker::Base.numerify('89########'),
        company_id: @company.id
      }
    end
    it "create client admin account " do
      post :new, params: params
      expect(response).to have_http_status(200)
    end
  end
  describe "Get#index" do
    it "show all client admins" do
      get :index
      expect(response).to have_http_status(200)
    end
  end
  describe "Get#show" do
    it "show client admin" do
      get :show, params: {id: @client_admin.id}
      expect(response).to have_http_status(200)
    end
  end
  describe "Put#edit" do
    let(:params) do {
      first_name: "John"
    }
    end
    it "edit client admin account" do
        put :update, params: {id: @client_admin.id, account: params}
        expect(response).to have_http_status(302)
    end
  end
end