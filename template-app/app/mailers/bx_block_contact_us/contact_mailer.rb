module BxBlockContactUs
  class ContactMailer < ApplicationMailer

    def send_mail(user)
      @user = user
      admin_emails = AdminUser.all

      mail(to: admin_emails.map(&:email),
      from: @user.email, 
      subject: "Welcome to Our Site #{@user.first_name}")
    end

    def send_profile_mail(user)
      @profile_user = user

      if @profile_user.type == "ClientUser"
        admins_mail = AdminUser.all
        client_admins = AccountBlock::Account.where(type: "ClientAdmin")
        lf_and_client_admin_mails = (admins_mail + client_admins).uniq
        mail(to: lf_and_client_admin_mails.map(&:email),
        from: @profile_user.email, 
        subject: "Welcome to Our Site #{@profile_user.first_name}")
      else
        clients_admins = AdminUser.all
        mail(to: clients_admins.map(&:email),
        from: @profile_user.email, 
        subject: "Welcome to Our Site #{@profile_user.first_name}")
      end
    end 
  end
end