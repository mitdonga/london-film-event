module BxBlockContactUs
  class ContactMailer < ApplicationMailer
    def send_mail(user)
      @user = user
      mail(to: 'brotaukiweuppoi-8051@yopmail.com', subject: "Welcome to Our Site #{@user.first_name}")
    end 
  end
end
