require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

include Warden::Test::Helpers

RSpec.describe Admin::ServicesController, type: :controller do
  render_views
  before(:each) do
    @admin = AdminUser.create!(email: 'test123@example.com', password: 'password', password_confirmation: 'password')
    @admin.save
    @service = FactoryBot.create(:service)
    3.times do
      FactoryBot.create(:input_field, inputable: @service)
    end

    sign_in @admin
  end
  describe "Service#new" do
    let(:params) do {
        name: Faker::Lorem.sentence(word_count: 2),
        description: Faker::Lorem.paragraph(sentence_count: 200)
      }
    end
    it "create service" do
      post :new, params: params
      expect(response).to have_http_status(200)
    end
  end
  describe "Get#index" do
    it "show all services" do
      get :index
      expect(response).to have_http_status(200)
    end
  end
  describe "Get#show" do
    it "show service" do
      get :show, params: {id: @service.id}
      expect(response).to have_http_status(200)
    end
  end
  describe "Put#edit" do
    let(:params) do {
      name: Faker::Lorem.sentence(word_count: 2)
    }
    end
    it "edit service" do
        put :update, params: {id: @service.id, account: params}
        expect(response).to have_http_status(302)
    end
  end
end