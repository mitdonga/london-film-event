module BxBlockInvoice    
    class InquiryJob < ApplicationJob
        queue_as :default
    
        def perform
            unsaved_inquiries = BxBlockInvoice::Inquiry.where(status: "unsaved").where("created_at >= ?", Time.now - 30.hours)
            puts "====== Removing #{unsaved_inquiries.size} unsaved inquiries ========"
            unsaved_inquiries.destroy_all if unsaved_inquiries.size > 0
        end
    end
end