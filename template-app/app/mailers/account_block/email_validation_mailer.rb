module AccountBlock
  class EmailValidationMailer < ApplicationMailer
    def activation_email
      @account = params[:account]
      @host = Rails.env.development? ? "http://localhost:3000" : params[:host]

      token = encoded_token

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
      @url = "#{@frontend_host}/forgot-password?token=#{token}"

      mail(
        to: @account.email,
        from: "builder.bx_dev@engineer.ai",
        subject: "Reset Password"
      ) do |format|
        format.html { render "reset_password_email" }
      end
    end

    private

    def encoded_token(expiry_time = 1.day.from_now)
      BuilderJsonWebToken.encode @account.id, expiry_time
    end
  end
end
