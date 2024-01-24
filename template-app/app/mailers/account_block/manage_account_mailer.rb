module AccountBlock
    class ManageAccountMailer < ApplicationMailer
        def send_welcome_mail_to_user(user_id)
            account = Account.find user_id

            template = BxBlockEmailNotifications::EmailTemplate.find_by_name("User Account Creation (Mail To User)")
            return unless template.present? && account.present?
            email_body = template.body.gsub('{first_name}', account.first_name).gsub('{last_name}', account.last_name).gsub('{email}', account.email).gsub('{user_name}', account.full_name)

            to_emails = account.email

            mail(
              to: to_emails,
              from: "builder.bx_dev@engineer.ai",
              subject: "New User Added",
              body: email_body,
              content_type: "text/html"
            )
        end

        def send_welcome_mail_to_admins(user_id)
            account = Account.find user_id

            template = BxBlockEmailNotifications::EmailTemplate.find_by_name("User Account Creation (Mail To LF Admin)")
            return unless template.present? && account.present?
            email_body = template.body.gsub('{first_name}', account.first_name).gsub('{last_name}', account.last_name).gsub('{email}', account.email).gsub('{full_phone_number}', account.full_phone_number)

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