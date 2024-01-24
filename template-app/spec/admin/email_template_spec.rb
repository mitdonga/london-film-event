require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

include Warden::Test::Helpers

RSpec.describe Admin::EmailTemplatesController, type: :controller do
  render_views
  before(:each) do
    @admin = AdminUser.create!(email: 'test123@example.com', password: 'password', password_confirmation: 'password')
    @admin.save
    3.times do
      @template = FactoryBot.create(:email_template)
    end
    sign_in @admin
  end
  describe "EmailTemplate#new" do
    let(:params) do {
        name: Faker::Lorem.sentence(word_count: 2),
        body: "Hi {user_name}, " + Faker::Lorem.paragraph(sentence_count: 200),
        dynamic_words: "user_name"
      }
    end
    it "create email template" do
      post :new, params: params
      expect(response).to have_http_status(200)
    end
  end
  describe "Get#index" do
    it "show all templates" do
      get :index
      expect(response).to have_http_status(200)
    end
  end
  describe "Get#show" do
    it "show template" do
      get :show, params: {id: @template.id}
      expect(response).to have_http_status(200)
    end
  end
  describe "Put#edit" do
    let(:params) do {
      name: Faker::Lorem.sentence(word_count: 2)
    }
    end
    it "edit template" do
        put :update, params: {id: @template.id, email_template: params}
        expect(response).to have_http_status(302)
    end
  end
end