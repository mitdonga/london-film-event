module BxBlockContactUs
  class ContactMailer < ApplicationMailer

    def send_mail(user)
      @user = user
      admin_emails = AdminUser.all

      mail(to: admin_emails.map(&:email),
      from: @user.email, 
      subject: "New Request is Submitted!") if admin_emails.any?
    end

    def send_profile_mail(user)
      @profile_user = user

      if @profile_user.type == "ClientUser"
        admins_mail = AdminUser.all
        client_admins = AccountBlock::Account.where(type: "ClientAdmin")
        lf_and_client_admin_mails = (admins_mail + client_admins).uniq
        mail(to: lf_and_client_admin_mails.map(&:email),
        from: @profile_user.email, 
        subject: "New Request is Submitted!") if lf_and_client_admin_mails.any?
      else
        clients_admins = AdminUser.all
        mail(to: clients_admins.map(&:email),
        from: @profile_user.email, 
        subject: "New Request is Submitted!") if clients_admins.any?
      end
    end

    def date_mail_from_user(user)
      @user = user
      admin_emails = AdminUser.all

      mail(to: admin_emails.map(&:email),
      from: @user.email, 
      subject: "New Request is Recieved!") if admin_emails.any?
    end

    def email_from_lf(filter_user,lf_admin_email)
      mail(to: filter_user,
      from: lf_admin_email,
      subject: "Approval Review Status Has Been Updated") if filter_user.present? && lf_admin_email.present?
    end

    def email_for_user(contact, user)
      if user.is_email_enabled?
        smtp_settings = Rails.configuration.action_mailer.smtp_settings
        smtp_username = smtp_settings.present? ? smtp_settings[:user_name] : "admin@ai.com"
  
        mail(to: contact.email,
        from: smtp_username,
        subject: "LF Admin will be in touch as soon as possible ") if contact.email.present?
      else
        Rails.logger.info("Emails not enabled for user #{user.id}")
      end
    end
  end
end