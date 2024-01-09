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
  end
end