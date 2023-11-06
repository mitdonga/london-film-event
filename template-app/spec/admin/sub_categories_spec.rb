require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

include Warden::Test::Helpers

RSpec.describe Admin::SubCategoriesController, type: :controller do
  render_views
  before(:each) do
    @admin = AdminUser.create!(email: 'test123@example.com', password: 'password', password_confirmation: 'password')
    @admin.save
    @service = FactoryBot.create(:service)
    @sub_category = FactoryBot.create(:sub_category, parent_id: @service.id)

    sign_in @admin
  end
  describe "SubCategory#new" do
    let(:params) do {
        name: Faker::Lorem.sentence(word_count: 2),
        description: Faker::Lorem.paragraph(sentence_count: 200),
        start_from: 2000,
        duration: 10,
        parent_id: @service.id
      }
    end
    it "create sub_category" do
      post :new, params: params
      expect(response).to have_http_status(200)
    end
  end
  describe "Get#index" do
    it "show all sub_categories" do
      get :index
      expect(response).to have_http_status(200)
    end
  end
  describe "Get#show" do
    it "show sub category" do
      get :show, params: {id: @sub_category.id}
      expect(response).to have_http_status(200)
    end
  end
  describe "Put#edit" do
    let(:params) do {
      name: Faker::Lorem.sentence(word_count: 2)
    }
    end
    it "edit sub category" do
        put :update, params: {id: @sub_category.id, account: params}
        expect(response).to have_http_status(302)
    end
  end
end