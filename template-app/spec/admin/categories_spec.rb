require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

include Warden::Test::Helpers

RSpec.describe Admin::CategoriesController, type: :controller do
  render_views
  before(:each) do
    @admin = AdminUser.create!(email: 'test123@example.com', password: 'password', password_confirmation: 'password')
    @admin.save
    @category = FactoryBot.create(:category)

    sign_in @admin
  end
  describe "Category#new" do
    let(:params) do {
        name: Faker::Lorem.sentence(word_count: 2),
        description: Faker::Lorem.paragraph(sentence_count: 200),
        catalogue_type: "all_packages",
        start_from: 200
      }
    end
    it "create category" do
      post :new, params: params
      expect(response).to have_http_status(200)
    end
  end
  describe "Get#index" do
    it "show all categories" do
      get :index
      expect(response).to have_http_status(200)
    end
  end
  describe "Get#show" do
    it "show category" do
      get :show, params: {id: @category.id}
      expect(response).to have_http_status(200)
    end
  end
  describe "Put#edit" do
    let(:params) do {
      name: Faker::Lorem.sentence(word_count: 2)
    }
    end
    it "edit category" do
        put :update, params: {id: @category.id, account: params}
        expect(response).to have_http_status(302)
    end
  end
end