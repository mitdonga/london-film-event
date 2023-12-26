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
      service = FactoryBot.create(:service)
      sub_category = FactoryBot.create(:sub_category, parent_id: @service.id)
    end
    @services = @company.services
    @csc = @company.company_sub_categories
    @cc = @company.company_categories
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
      expect(@company.services_sub_categories_data.class).to eq(Array)
      expect(@company.sub_categories_with_service.class).to eq(Hash)
    end
  end

  describe "Put#edit" do
    let(:params) do {
      "name" => "Amazon Inc",
      "company_sub_categories" => { "#{@csc[0].id.to_s}" => @csc[0].as_json },
      "company_categories" => { "#{@cc[0].id.to_s}" => @cc[0].as_json }
    }end
    it "edit company" do
        put :update, params: {id: @company.id, bx_block_invoice_company: params}
        expect(response).to have_http_status(302)
    end
  end
end