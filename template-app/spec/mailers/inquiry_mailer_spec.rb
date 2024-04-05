require "rails_helper"

RSpec.describe BxBlockInvoice::InquiryMailer, type: :mailer do
    include_context "setup data"

    describe '#send_inquiry_details_to' do
        let(:mail) { described_class.send_inquiry_details_to(@inquiry_2.id).deliver_now }
        it 'renders the subject' do
            expect(mail.subject).to eq('User Requested For Quote')
        end
        
        it 'renders the receiver email' do
            expect(mail.to).to eq([@client_admin_1.email])
        end
        
        it 'renders the sender email' do
            expect(mail.from).to eq(["builder.bx_dev@engineer.ai"])
        end
    end

    describe '#inquiry_approved' do
        let(:mail) { described_class.inquiry_approved(@inquiry_4.id).deliver_now }
        it 'renders the subject' do
            expect(mail.subject).to eq('Admin Approved Your Enquiry')
        end
        
        it 'renders the receiver email' do
            expect(mail.to).to eq([@client_user_2.email])
        end
        
        it 'renders the sender email' do
            expect(mail.from).to eq(["builder.bx_dev@engineer.ai"])
        end
    end

    describe '#inquiry_rejected' do
        let(:mail) { described_class.inquiry_rejected(@inquiry_4.id).deliver_now }
        it 'renders the subject' do
            expect(mail.subject).to eq('Enquiry Rejected By Admin')
        end
        
        it 'renders the receiver email' do
            expect(mail.to).to eq([@client_user_2.email])
        end
        
        it 'renders the sender email' do
            expect(mail.from).to eq(["builder.bx_dev@engineer.ai"])
        end
    end

    describe '#inquiry_approved_mail_to_admins' do
        let(:mail) { described_class.inquiry_approved_mail_to_admins(@inquiry_4.id).deliver_now }
        it 'renders the subject' do
            expect(mail.subject).to eq('Enquiry Approved')
        end
        
        it 'renders the receiver email' do
            expect(mail.to.size).to be >= 1
        end
        
        it 'renders the sender email' do
            expect(mail.from).to eq(["builder.bx_dev@engineer.ai"])
        end
    end
end