require "rails_helper"

RSpec.describe BxBlockInvoice::InquiryMailer, type: :mailer do
    FROM_EMAIL = "builder.bx_dev@engineer.ai"
    SUBJECT = 'renders the subject'
    RENDER_R_EMAIL = 'renders the receiver email'
    RENDER_F_EMAIL = 'renders the sender email'

    include_context "setup data"

    describe '#send_inquiry_details_to' do
        let(:mail) { described_class.send_inquiry_details_to(@inquiry_2.id).deliver_now }
        it SUBJECT do
            expect(mail.subject).to eq('New London Filmed Package Approval Request')
        end
        
        it RENDER_R_EMAIL do
            expect(mail.to).to eq([@client_admin_1.email])
        end
        
        it RENDER_F_EMAIL do
            expect(mail.from).to eq([FROM_EMAIL])
        end
    end

    describe '#inquiry_approved' do
        let(:mail) { described_class.inquiry_approved(@inquiry_4.id).deliver_now }
        it SUBJECT do
            expect(mail.subject).to eq('Your Package Has Been Approved - London Filmed Booking Platform')
        end
        
        it RENDER_R_EMAIL do
            expect(mail.to).to eq([@client_user_2.email])
        end
        
        it RENDER_F_EMAIL do
            expect(mail.from).to eq([FROM_EMAIL])
        end
    end

    describe '#inquiry_rejected' do
        let(:mail) { described_class.inquiry_rejected(@inquiry_4.id).deliver_now }
        it SUBJECT do
            expect(mail.subject).to eq('Enquiry Rejected By Admin')
        end
        
        it RENDER_R_EMAIL do
            expect(mail.to).to eq([@client_user_2.email])
        end
        
        it RENDER_F_EMAIL do
            expect(mail.from).to eq([FROM_EMAIL])
        end
    end

    describe '#inquiry_approved_mail_to_admins' do
        let(:mail) { described_class.inquiry_approved_mail_to_admins(@inquiry_4.id).deliver_now }
        it SUBJECT do
            expect(mail.subject).to eq('Enquiry Approved')
        end
        
        it RENDER_R_EMAIL do
            expect(mail.to.size).to be >= 1
        end
        
        it RENDER_F_EMAIL do
            expect(mail.from).to eq([FROM_EMAIL])
        end
    end
end