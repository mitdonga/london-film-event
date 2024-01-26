module AccountBlock
    class ManageAccountMailer < ApplicationMailer
      WATER_MARK_HTML = '<p data-f-id="pbf" style="text-align: center; font-size: 14px; margin-top: 30px; opacity: 0.65; font-family: sans-serif;">Powered by <a href="https://www.froala.com/wysiwyg-editor?pb=1" title="Froala Editor">Froala Editor</a></p>'

        def send_welcome_mail_to_user(user_id)
            account = Account.find user_id

            template = BxBlockEmailNotifications::EmailTemplate.find_by_name("User Account Creation (Mail To User)")
            return unless template.present? && account.present?
            email_body = template.body.gsub('{first_name}', account.first_name).gsub('{last_name}', account.last_name).gsub('{email}', account.email).gsub('{user_name}', account.full_name).gsub(WATER_MARK_HTML, '')

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
            email_body = template.body.gsub('{first_name}', account.first_name).gsub('{last_name}', account.last_name).gsub('{email}', account.email).gsub('{full_phone_number}', account.full_phone_number).gsub(WATER_MARK_HTML, '')

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