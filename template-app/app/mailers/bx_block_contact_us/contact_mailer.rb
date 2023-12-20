module BxBlockContactUs
  class ContactMailer < ApplicationMailer
    def send_mail(user)
      @user = user
      mail(to: 'admin01@yopmail.com',from: @user.email, subject: "Welcome to Our Site #{@user.first_name}")
    end 
  end
end
