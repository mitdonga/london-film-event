require "rails_helper"

RSpec.describe BxBlockContactUs::ContactMailer, type: :mailer do
  describe '#send_mail' do

    let!(:account) { FactoryBot.create(:account) }

    let!(:user) { FactoryBot.create(:contact, account_id: account.id) }

    let(:mail) { BxBlockContactUs::ContactMailer.send_mail(user) }

    it 'renders the headers' do
      expect(mail.subject).to include("Welcome to Our Site #{user.first_name}")
    end
  end
end
