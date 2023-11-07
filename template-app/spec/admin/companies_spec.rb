require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

include Warden::Test::Helpers

RSpec.describe Admin::CompaniesController, type: :controller do
  render_views
  before(:each) do
    @admin = AdminUser.create!(email: 'test123@example.com', password: 'password', password_confirmation: 'password')
    @admin.save
    @company = FactoryBot.create(:company)
    @service = FactoryBot.create(:service)
    3.times do
      sub_category = FactoryBot.create(:sub_category, parent_id: @service.id)
    end
    sign_in @admin
  end
  describe "Post#new" do
    let(:params) do {
        name: "Builder AI",
        address: "Abc street, London, UK",
        city: "London",
        zip_code: "10001",
        phone_number: Faker::Base.numerify('+918#########'),
        email: Faker::Internet.email
      }
    end
    it "create company" do
      post :new, params: params
      expect(response).to have_http_status(200)
    end
  end
  describe "Get#index" do
    it "show all companies" do
      get :index
      expect(response).to have_http_status(200)
    end
  end
  describe "Get#show" do
    it "show company" do
      get :show, params: {id: @company.id}
      expect(response).to have_http_status(200)
    end
  end
  describe "Put#edit" do
    let(:params) do {
      name: "Amazon Inc"
    }
    end
    it "edit company" do
        put :update, params: {id: @company.id, account: params}
        expect(response).to have_http_status(302)
    end
  end
end