require 'rails_helper'
RSpec.describe BxBlockHelpCentre::QuestionAnswerController, type: :controller do
  describe 'GET #index' do
    context 'when question answers are present' do
      before do 
        @company = FactoryBot.create(:company) 
        @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
        @token = BuilderJsonWebToken.encode(@client_admin.id)
        @question_answer = FactoryBot.create(:question_answer) 
      end

      it 'returns a successful response with a list of question answers' do
        get "index", params: {token: @token}
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when no question answers are present' do
      before do 
        @company = FactoryBot.create(:company) 
        @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
        @token = BuilderJsonWebToken.encode(@client_admin.id)
      end

      it 'returns an unprocessable entity response with an error message' do
        get "index", params: {token: @token}
        json = JSON.parse(response.body)
        expect(json["errors"][0]["message"]).to eq("No question found.")
      end
    end    
  end

  describe 'GET #search_question' do
    context 'It will get the searched question with answer' do
      before do 
        @company = FactoryBot.create(:company) 
        @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
        @token = BuilderJsonWebToken.encode(@client_admin.id)
        @question_answer1 = FactoryBot.create(:question_answer) 
      end

      it 'returns a successful response with a list of question answers which are searched' do
        get "search_question", params: {token: @token, question: @question_answer1.question}
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when no question answers are present' do
      before do 
        @company = FactoryBot.create(:company) 
        @client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
        @token = BuilderJsonWebToken.encode(@client_admin.id)
      end

      it 'will returns unprocessable entity response with an error message' do
        get "search_question", params: {token: @token}
        json = JSON.parse(response.body)
        expect(json["errors"][0]["message"]).to eq("No search query provided.")
      end
    end    
  end
end
