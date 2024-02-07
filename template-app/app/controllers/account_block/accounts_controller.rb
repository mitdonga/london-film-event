module AccountBlock
  class AccountsController < ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation

    before_action :validate_json_web_token, except: [:reset_password_email, :all_company_users]
    before_action :current_user, except: [:create, :reset_password_email, :all_company_users]
    # before_action :validate_json_web_token, only: [:search, :change_email_address, :change_phone_number, :specific_account, :logged_user, :change_password, :update, :add_client_user]

    # before_action :current_user, only: [:change_password, :update, :add_client_user]
    before_action :validate_client_admin, only: [:add_client_user, :update_client_user, :client_users, :remove_user, :company_users, :send_account_activation_email]
    before_action :validate_client_admin_permission, only: [:add_client_user, :update_client_user, :remove_user, :send_account_activation_email]

    def create
      case params[:data][:type] #### rescue invalid API format
      when "sms_account"
        validate_json_web_token

        unless valid_token?
          return render json: {errors: [
            {token: "Invalid Token"}
          ]}, status: :bad_request
        end

        begin
          @sms_otp = SmsOtp.find(@token[:id])
        rescue ActiveRecord::RecordNotFound => e
          return render json: {errors: [
            {phone: "Confirmed Phone Number was not found"}
          ]}, status: :unprocessable_entity
        end

        params[:data][:attributes][:full_phone_number] =
          @sms_otp.full_phone_number
        @account = SmsAccount.new(jsonapi_deserialize(params))
        @account.activated = true
        if @account.save
          render json: SmsAccountSerializer.new(@account, meta: {
            token: encode(@account.id)
          }).serializable_hash, status: :created
        else
          render json: {errors: format_activerecord_errors(@account.errors)},
            status: :unprocessable_entity
        end

      when "email_account"
        account_params = jsonapi_deserialize(params)

        query_email = account_params["email"].downcase
        account = EmailAccount.where("LOWER(email) = ?", query_email).first

        validator = EmailValidation.new(account_params["email"])

        if account || !validator.valid?
          return render json: {errors: [
            {account: "Email invalid"}
          ]}, status: :unprocessable_entity
        end

        @account = EmailAccount.new(jsonapi_deserialize(params))
        @account.platform = request.headers["platform"].downcase if request.headers.include?("platform")

        if @account.save
          EmailValidationMailer
            .with(account: @account, host: request.base_url)
            .activation_email.deliver
          render json: EmailAccountSerializer.new(@account, meta: {
            token: encode(@account.id)
          }).serializable_hash, status: :created
        else
          render json: {errors: format_activerecord_errors(@account.errors)},
            status: :unprocessable_entity
        end

      when "social_account"
        @account = SocialAccount.new(jsonapi_deserialize(params))
        @account.password = @account.email
        if @account.save
          render json: SocialAccountSerializer.new(@account, meta: {
            token: encode(@account.id)
          }).serializable_hash, status: :created
        else
          render json: {errors: format_activerecord_errors(@account.errors)},
            status: :unprocessable_entity
        end

      else
        render json: {errors: [
          {account: "Invalid Account Type"}
        ]}, status: :unprocessable_entity
      end
    end

    # def search
    #   @accounts = Account.where(activated: true)
    #     .where("first_name ILIKE :search OR " \
    #                        "last_name ILIKE :search OR " \
    #                        "email ILIKE :search", search: "%#{search_params[:query]}%")
    #   if @accounts.present?
    #     render json: AccountSerializer.new(@accounts, meta: {message: "List of users."}).serializable_hash, status: :ok
    #   else
    #     render json: {errors: [{message: "Not found any user."}]}, status: :ok
    #   end
    # end

    def change_email_address
      query_email = params["email"]
      account = EmailAccount.where("LOWER(email) = ?", query_email).first

      validator = EmailValidation.new(query_email)

      if account || !validator.valid?
        return render json: {errors: "Email invalid"}, status: :unprocessable_entity
      end
      @account = Account.find(@token.id)
      if @account.update(email: query_email)
        render json: AccountSerializer.new(@account).serializable_hash, status: :ok
      else
        render json: {errors: "account user email id is not updated"}, status: :ok
      end
    end

    # def change_phone_number
    #   @account = Account.find(@token.id)
    #   if @account.update(full_phone_number: params["full_phone_number"])
    #     render json: AccountSerializer.new(@account).serializable_hash, status: :ok
    #   else
    #     render json: {errors: "account user phone_number is not updated"}, status: :ok
    #   end
    # end

    def specific_account
      @account = Account.find(@token.id)
      if @account.present?
        render json: AccountSerializer.new(@account).serializable_hash, status: :ok
      else
        render json: {errors: "account does not exist"}, status: :ok
      end
    end
    

    def index
      @accounts = Account.all
      if @accounts.present?
        render json: AccountSerializer.new(@accounts).serializable_hash, status: :ok
      else
        render json: {errors: "accounts data does not exist"}, status: :ok
      end
    end

    def change_password
      current_password = params[:current_password]
      new_password, confirm_password = params[:new_password], params[:confirm_password]

      if current_password.present? && new_password.present? && new_password == confirm_password
        data = BxBlockProfile::ChangePasswordCommand.execute(@account.id, current_password, new_password)
        status, result = *data
        if status == :created
          render json: { message: "Password updated" }, status: status
        else
          render json: { message: "Oops, something went wrong!", errors: result }, status: status
        end
      else
        render json: {error: "Please enter valid password"}, status: :unprocessable_entity
      end
    end

    def reset_password_email
      email = params[:email].presence || ""
      validator = EmailValidation.new(email)
      return render json: { message: "Invalid Email" }, status: :unprocessable_entity unless validator.valid?

      account = Account.find_by_email(email)
      return render json: { message: "Account not found" }, status: :unprocessable_entity unless account.present?
      
      frontend_host = request.headers['Origin'] || ENV['FRONTEND_URL'] || 'http://localhost:3001'
      EmailValidationMailer.with(account: account, frontend_host: frontend_host).reset_password_email.deliver
      render json: { message: "Password reset link has been sent. Kindly check your email inbox for further instructions" }, status: :ok
    end

    def reset_password
      password = params[:password]
      confirm_password = params[:confirm_password]
      return render json: { message: "Password and confirm password doesn't match" }, status: :unprocessable_entity if password != confirm_password
      password_validation = PasswordValidation.new(password)
      is_valid = password_validation.valid?
      error_message = password_validation.errors.full_messages.first
      if is_valid && error_message.nil?
        if @account.update(password: password, activated: true, should_reset_password: false)
          render json: {message: "Password updated successfully"}, status: :ok
        else
          render json: {message: "Unable to update password. Something went wrong"}, status: :unprocessable_entity
        end
      else
        render json: {message: "Please enter valid password", errors: password_validation.errors.full_messages}, status: :unprocessable_entity
      end
    end

    def update_for_notification
      if @account.email_enable == true
        @account.update(email_enable: false)
        render json: {message: "email is disabled"}, status: :ok
      else
        @account.update(email_enable: true)
        render json: {message: "email is enabled"}, status: :ok
      end   if @account.present?
    end

    def update
      if @account.update(account_params)
        render json: AccountSerializer.new(@account).serializable_hash, status: :ok
      else
        render json: {errors: @account.errors.full_messages}, status: :unprocessable_entity
      end
    end

    def add_client_user
      client_user = ClientUser.new(account_params)
      client_user.client_admin_id = @account.id
      client_user.company_id = @account.company_id
      if client_user.save
        return render json: { 
          message: "Client user created successfully", 
          client_user: AccountSerializer.new(client_user).serializable_hash
        }, status: :created
      else
        return render json: { 
          message: "Failed to create client user", 
          errors: client_user.errors.full_messages 
        }, status: :unprocessable_entity
      end
    end

    def update_client_user
      client_user = @account.company.accounts.find_by_id(params[:client_user_id]) rescue nil
      return render json: {message: "User not present or you're not authorized to update this user"}, status: :unprocessable_entity unless client_user.present?
      if client_user.update(account_params)
        render json: {message: "User successfully updated", client_user: AccountSerializer.new(client_user).serializable_hash}, status: :ok
      else
        render json: {message: "Failed to update user details", errors: client_user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def client_users
      client_users = @account.client_users
      render json: { message: "Found #{client_users.size} users", client_users: AccountSerializer.new(client_users).serializable_hash }, status: :ok
    end

    def company_users
      company_users = @account.company.accounts.where.not(id: @account.id)
      render json: { message: "Found #{company_users.size} users", company_users: AccountSerializer.new(company_users).serializable_hash }, status: :ok
    end

    def remove_user
      client_user = @account.company.accounts.find_by_id(params[:user_id]) rescue nil
      return render json: {message: "User not present or you're not authorized to delete this user"}, status: :unauthorized unless client_user.present?
      if client_user && client_user.destroy
        render json: { message: "Client user removed successfully" }, status: :ok
      else
        render json: { message: "Unable to remove client user" }, status: :unprocessable_entity
      end
    end

    def send_account_activation_email
      client_user = @account.company.accounts.find_by_id(params[:user_id]) rescue nil
      return render json: {message: "User not present or you're not authorized"}, status: :unauthorized unless client_user.present?
      EmailValidationMailer.with(account: client_user, host: request.base_url).activation_email.deliver
      render json: {message: "Success"}, status: :ok
    end

    # def logged_user
    #   @account = Account.find(@token.id)
    #   if @account.present?
    #     render json: AccountSerializer.new(@account).serializable_hash, status: :ok
    #   else
    #     render json: {errors: "account does not exist"}, status: :ok
    #   end
    # end

    def all_company_users
      data = BxBlockInvoice::Company.find(params[:company_id]).accounts.where(type: "ClientAdmin").map {|u| {name: u.full_name, id: u.id}} rescue []
      render json: {data: data}
    end

    private

    def account_params
      params.require(:account).permit(:first_name, :last_name, :country_code, :email, :phone_number, :device_id, :job_title, :account_type, :company_id)
    end

    def validate_client_admin
      return render json: { errors: ["You're unauthorized to perform this action", "Only client admin can perform this action"] }, status: :unauthorized unless @account.type == "ClientAdmin"
    end

    def validate_client_admin_permission
      return render json: { errors: ["You don't have permission to perform this action"] }, status: :unauthorized unless @account.type == "ClientAdmin" && @account.can_create_accounts
    end

    def current_user
      @account = Account.find(@token.id)
    end

    def encode(id)
      BuilderJsonWebToken.encode id
    end

    def search_params
      params.permit(:query)
    end
  end
end
