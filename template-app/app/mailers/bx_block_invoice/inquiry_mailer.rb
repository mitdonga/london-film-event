module BxBlockInvoice
    class InquiryMailer < ApplicationMailer
        before_action :attach_logos
        def send_inquiry_details_to(inquiry_id, is_bespoke = false)
            
            inquiry = BxBlockInvoice::Inquiry.find inquiry_id
            user = inquiry.user
            event_name = inquiry.event_name
            company_name = user.company.name
            meeting_link = user.company.meeting_link
            quote_link = Rails.application.config.frontend_host + "/request-quote/#{inquiry.id}"
            ac_quote_link = Rails.application.config.base_url + "/admin/bespoke_inquiries/#{inquiry.id}"

            template = is_bespoke ?
                      BxBlockEmailNotifications::EmailTemplate.find_by_name("Client User/Admin Submitted Bespoke Request") :
                      BxBlockEmailNotifications::EmailTemplate.find_by_name("Client User Request for Quote (All Packages or Previous Packages)")
            return unless template.present? && inquiry.present?
            email_subject = is_bespoke ? "User Requested For Bespoke Request" : "User Requested For Quote"
            email_body = template.body
                          .gsub('{first_name}', user.first_name)
                          .gsub('{user_name}', user.full_name)
                          .gsub('{service_name}', inquiry.service.name)
                          .gsub('{sub_category_name}', inquiry.sub_category.name)
                          .gsub('{event_date}', inquiry.event_date.to_s)
                          .gsub('{event_name}', event_name.to_s)
                          .gsub('{company_name}', company_name.to_s)
                          .gsub('{meeting_link}', meeting_link.to_s)
                          .gsub('{ac_quote_link}', quote_link.to_s)
            @email_body = remove_water_mark(email_body)
            to_emails = is_bespoke ? AdminUser.all.pluck(:email) : user.company.company_admins.pluck(:email)

            # mail(
            #   to: to_emails,
            #   from: "builder.bx_dev@engineer.ai",
            #   subject: email_subject,
            #   body: email_body,
            #   content_type: "text/html"
            # )
            mail(to: to_emails, subject: email_subject) do |format|
              format.html { render "account_block/email_template" }
            end
        end
        
        def inquiry_approved(inquiry_id)
            
            inquiry = BxBlockInvoice::Inquiry.find inquiry_id
            user = inquiry.user
            return if user.is_admin?
            account_manager_name = inquiry.user.client_admin.full_name rescue ""
            approved_by_admin_name = inquiry.approved_by_client_admin.full_name rescue ""
            meeting_link = user.company.meeting_link rescue ""

            template = BxBlockEmailNotifications::EmailTemplate.find_by_name("Client Admin Approving a Package (Mail to user)")
            return unless template.present? && inquiry.present?

            email_body = template.body
                          .gsub('{first_name}', user.first_name)
                          .gsub('{user_name}', user.full_name)
                          .gsub('{service_name}', inquiry.service.name)
                          .gsub('{sub_category_name}', inquiry.sub_category.name)
                          .gsub('{event_date}', inquiry.event_date.to_s)
                          .gsub('{event_name}', inquiry.event_name.to_s)
                          .gsub('{meeting_link}', meeting_link.to_s)
                          .gsub('{account_manager_name}', account_manager_name.to_s)
                          .gsub('{approved_by_admin_name}', approved_by_admin_name)
            @email_body = remove_water_mark(email_body)
            # mail(
            #   to: user.email,
            #   from: "builder.bx_dev@engineer.ai",
            #   subject: "Admin Approved Your Enquiry",
            #   body: email_body,
            #   content_type: "text/html"
            # )
            mail(to: user.email, subject: "Admin Approved Your Enquiry") do |format|
              format.html { render "account_block/email_template" }
            end
        end

        def inquiry_approved_mail_to_admins(inquiry_id)
          inquiry = BxBlockInvoice::Inquiry.find inquiry_id
          user = inquiry.user
          approved_by_admin_name = inquiry.approved_by_client_admin.full_name rescue ""

          template = BxBlockEmailNotifications::EmailTemplate.find_by_name("Client Admin Approving a Package (Mail to admin)")
          return unless template.present? && inquiry.present?

          email_body = template.body
                        .gsub('{first_name}', user.first_name)
                        .gsub('{user_name}', user.full_name)
                        .gsub('{client_name}', user.full_name)
                        .gsub('{service_name}', inquiry.service.name)
                        .gsub('{sub_category_name}', inquiry.sub_category.name)
                        .gsub('{event_date}', inquiry.event_date.to_s)
                        .gsub('{approved_by_admin_name}', approved_by_admin_name)
          @email_body = remove_water_mark(email_body)
          to_emails = AdminUser.all.pluck(:email) + user.company.company_admins.pluck(:email)
          # mail(
          #   to: to_emails,
          #   from: "builder.bx_dev@engineer.ai",
          #   subject: "Enquiry Approved",
          #   body: email_body,
          #   content_type: "text/html"
          # )
          mail(to: to_emails, subject: "Enquiry Approved") do |format|
            format.html { render "account_block/email_template" }
          end
        end

        def inquiry_rejected(inquiry_id)
          inquiry = BxBlockInvoice::Inquiry.find inquiry_id
          user = inquiry.user
          rejected_by_admin = inquiry.rejected_by_lf&.email || inquiry.rejected_by_ca&.full_name

          template = BxBlockEmailNotifications::EmailTemplate.find_by_name("Inquiry Rejected By Admin (Mail to User)")
          return unless template.present? && inquiry.present?

          email_body = template.body
                        .gsub('{first_name}', user.first_name)
                        .gsub('{user_name}', user.full_name)
                        .gsub('{service_name}', inquiry.service.name)
                        .gsub('{sub_category_name}', inquiry.sub_category.name)
                        .gsub('{event_date}', inquiry.event_date.to_s)
                        .gsub('{rejected_by_admin_name}', rejected_by_admin || "")
          @email_body = remove_water_mark(email_body)
          # mail(
          #   to: user.email,
          #   from: "builder.bx_dev@engineer.ai",
          #   subject: "Enquiry Rejected By Admin",
          #   body: email_body,
          #   content_type: "text/html"
          # )
          mail(to: user.email, subject: "Enquiry Rejected By Admin") do |format|
            format.html { render "account_block/email_template" }
          end
        end
    end
end