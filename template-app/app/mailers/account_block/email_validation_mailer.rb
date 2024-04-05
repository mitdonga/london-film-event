module AccountBlock
  class EmailValidationMailer < ApplicationMailer
    def activation_email
      @account = params[:account]
      @host = Rails.env.development? ? "http://localhost:3000" : params[:host]

      token = encoded_token(2.days.from_now)

      @url = "#{@host}/account/accounts/email_confirmation?token=#{token}"
      @password = @account.generate_password

      mail(
        to: @account.email,
        from: "builder.bx_dev@engineer.ai",
        subject: "Account activation"
      ) do |format|
        format.html { render "activation_email" }
      end
    end

    def reset_password_email
      @account = params[:account]
      @frontend_host = params[:frontend_host]
      token = encoded_token(10.minutes.from_now)
      @url = "#{@frontend_host}/NewPassword?token=#{token}"

      template = BxBlockEmailNotifications::EmailTemplate.find_by_name("Password Reset (Client User/Admin)")
      return unless template.present? && @account.present?
    
      button_html = "<a href='#{@url}' style='background-color: #4CAF50; color: white; padding: 10px 20px; text-align: center; text-decoration: none; display: inline-block; font-size: 16px; cursor: pointer; border-radius: 5px;'>Reset Password</a>"

      email_body = template.body
                    .gsub('{first_name}', @account.first_name)
                    .gsub('{last_name}', @account.last_name)
                    .gsub('{user_name}', @account.full_name)
                    .gsub('{password_reset_button}', button_html)
                    .gsub('{password_reset_url}', @url)

      email_body = remove_water_mark(email_body)
      mail(
        to: @account.email,
        from: "builder.bx_dev@engineer.ai",
        subject: "Reset Password",
        body: email_body,
        content_type: "text/html"
      )
    end

    private

    def encoded_token(expiry_time = 1.day.from_now)
      BuilderJsonWebToken.encode @account.id, expiry_time
    end
  end
end
