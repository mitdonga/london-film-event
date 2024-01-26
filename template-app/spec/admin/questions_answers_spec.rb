require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

include Warden::Test::Helpers

RSpec.describe Admin::FaqsController, type: :controller do
  render_views
  before(:each) do
    @admin = AdminUser.create!(email: 'test123@example.com', password: 'password', password_confirmation: 'password')
    @admin.save
    @account = FactoryBot.create(:account)
    @service = FactoryBot.create(:service)
    @sub_category = FactoryBot.create(:sub_category, parent_id: @service.id)
    @faq = FactoryBot.create(:question_answer)

    sign_in @admin
  end

  describe "Post#new" do
    let(:params) do {
        question: Faker::Lorem.question,
        answer:  Faker::Lorem.paragraph
      }
    end
    it "create faq" do
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


  describe "Get#show" do
    it "show contact requests" do
      get :show, params: {id: @faq.id}
      expect(response).to have_http_status(200)
    end
  end

  describe "Put#edit" do
    let(:params) do {
      "question" => "test question"
    }end
    it "edit company" do
        put :update, params: {id: @faq.id, question_answer: params}
        expect(response).to have_http_status(302)
    end
  end
end