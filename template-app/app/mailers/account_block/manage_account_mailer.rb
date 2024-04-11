module AccountBlock
    class ManageAccountMailer < ApplicationMailer
        before_action :attach_logos

        def send_welcome_mail_to_user(user_id)
            account = Account.find user_id

            template = BxBlockEmailNotifications::EmailTemplate.where("name ilike ?", "%User Account Creation (Mail To User)%").first
            return unless template.present? && account.present? && !account.is_admin?
            # @user = account
            # @manager = account.client_admin
            # @booking_link = account.company.meeting_link
            account_manager_first_name = account.client_admin.full_name rescue ""
            account_manager_email = account.client_admin.email rescue ""
            meeting_link = account.company.meeting_link
            website_url = Rails.application.config.frontend_host + "/LandingPage"
            book_call_button = "<div class='call-to-action'><div class='overlay'></div><a class='button' href='#{meeting_link}'>Book a call</div></div>"

            email_body = template.body
                          .gsub('{first_name}', account.first_name.to_s)
                          .gsub('{last_name}', account.last_name.to_s)
                          .gsub('{account_manager_first_name}', account_manager_first_name.to_s)
                          .gsub('{account_manager_email}', account_manager_email.to_s)
                          .gsub('{email}', account.email.to_s)
                          .gsub('{meeting_link}', meeting_link.to_s)
                          .gsub('{website_url}', website_url.to_s)
                          .gsub('{user_name}', account.full_name.to_s)
                          .gsub('{book_call_button}', book_call_button)
            @email_body = remove_water_mark(email_body)
            to_emails = account.email
            # mail(
            #   to: to_emails,
            #   from: "builder.bx_dev@engineer.ai",
            #   subject: "Welcome To London Filmed",
            #   body: email_body,
            #   content_type: "text/html"
            # )
            mail(to: to_emails, subject: "Welcome To London Filmed") do |format|
              format.html { render "account_block/email_template" }
            end
        end

        def send_welcome_mail_to_admins(user_id)
            account = Account.find user_id

            template = BxBlockEmailNotifications::EmailTemplate.find_by_name("User Account Creation (Mail To LF Admin)")
            return unless template.present? && account.present?
            email_body = template.body.gsub('{first_name}', account.first_name).gsub('{last_name}', account.last_name).gsub('{email}', account.email).gsub('{full_phone_number}', account.full_phone_number)
            email_body = remove_water_mark(email_body)
            to_emails = AdminUser.all.pluck(:email)
            mail(
              to: to_emails.presence || "testadmin@yopmail.com",
              from: "builder.bx_dev@engineer.ai",
              subject: "New User Added",
              body: email_body,
              content_type: "text/html"
            )
        end
    end
end