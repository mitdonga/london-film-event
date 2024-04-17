require "rails_helper"

RSpec.describe AccountBlock::ManageAccountMailer, type: :mailer do
    FROM_EMAIL = "builder.bx_dev@engineer.ai"
    SUBJECT = 'renders the subject'
    RENDER_R_EMAIL = 'renders the receiver email'
    RENDER_F_EMAIL = 'renders the sender email'
    include_context "setup data"

    describe '#send_welcome_mail_to_user' do
        let(:mail) { described_class.send_welcome_mail_to_user(@client_user_1.id).deliver_now }
        it SUBJECT do
            expect(mail.subject).to eq('Welcome to the London Filmed Booking Platform')
        end
        
        it RENDER_R_EMAIL do
            expect(mail.to).to eq([@client_user_1.email])
        end
        
        it RENDER_F_EMAIL do
            expect(mail.from).to eq([FROM_EMAIL])
        end
    end

    describe '#send_welcome_mail_to_admins' do
        let(:mail) { described_class.send_welcome_mail_to_admins(@client_admin_1.id).deliver_now }
        it SUBJECT do
            expect(mail.subject).to eq('LF Platform: New Account Created')
        end
        
        it RENDER_R_EMAIL do
            expect(mail.to.size).to be >= 1
        end
        
        it RENDER_F_EMAIL do
            expect(mail.from).to eq([FROM_EMAIL])
        end
    end
end