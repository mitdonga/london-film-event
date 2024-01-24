module BxBlockInvoice
    class InquiryMailer < ApplicationMailer
        def send_inquiry_details_to(inquiry_id)
            
            inquiry = BxBlockInvoice::Inquiry.find inquiry_id
            user = inquiry.user

            template = BxBlockEmailNotifications::EmailTemplate.find_by_name("Client User Request for Quote (All Packages or Previous Packages)")
            return unless template.present? && inquiry.present?

            email_body = template.body
                          .gsub('{first_name}', user.first_name)
                          .gsub('{user_name}', user.full_name)
                          .gsub('{service_name}', inquiry.service.name)
                          .gsub('{sub_category_name}', inquiry.sub_category.name)
                          .gsub('{event_date}', inquiry.event_date.to_s)

            to_emails = user.company.company_admins.pluck(:email)

            mail(
              to: to_emails,
              from: "builder.bx_dev@engineer.ai",
              subject: "User Requested For Quote",
              body: email_body,
              content_type: "text/html"
            )
        end
        
        def inquiry_approved(inquiry_id)
            
            inquiry = BxBlockInvoice::Inquiry.find inquiry_id
            user = inquiry.user

            template = BxBlockEmailNotifications::EmailTemplate.find_by_name("Client Admin Approving a Package")
            return unless template.present? && inquiry.present?

            email_body = template.body
                          .gsub('{first_name}', user.first_name)
                          .gsub('{user_name}', user.full_name)
                          .gsub('{service_name}', inquiry.service.name)
                          .gsub('{sub_category_name}', inquiry.sub_category.name)
                          .gsub('{event_date}', inquiry.event_date.to_s)


            mail(
              to: user.email,
              from: "builder.bx_dev@engineer.ai",
              subject: "Admin Approved Your Enquiry",
              body: email_body,
              content_type: "text/html"
            )
        end
    end
end