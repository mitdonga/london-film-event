module BxBlockLogin
  class AccountAdapter
    include Wisper::Publisher

    def login_account(account_params)
      case account_params.type
      when 'sms_account'
        phone = Phonelib.parse(account_params.full_phone_number).sanitized
        account = AccountBlock::SmsAccount.find_by(
          full_phone_number: phone,
          activated: true)
      when 'email_account'
        email = account_params.email.downcase

        account = AccountBlock::Account
          .where('LOWER(email) = ?', email)
          .first
      when 'social_account'
        account = AccountBlock::SocialAccount.find_by(
          email: account_params.email.downcase,
          unique_auth_id: account_params.unique_auth_id,
          activated: true)
      end

      unless account.present?
        broadcast(:account_not_found)
        return
      end

      if account.present? && !account.activated
        broadcast(:account_not_activated)
        return
      end

      if account.authenticate(account_params.password)
        token, refresh_token = generate_tokens(account.id)
        if account_params.password == account.generate_password && !account.should_reset_password
          account.update(should_reset_password: true)
        elsif account_params.password != account.generate_password && account.should_reset_password
          account.update(should_reset_password: false)
        end
        broadcast(:successful_login, account, token, refresh_token)
      else
        broadcast(:failed_login)
      end
    end

    def logout_account(acc)
      case acc.type
      when 'sms_account'
        phone = Phonelib.parse(acc.full_phone_number).sanitized
        account = AccountBlock::SmsAccount.find_by(
          full_phone_number: phone,
          activated: true
        )
      when 'email_account'
        email = acc.email.downcase
        account = AccountBlock::Account
          .where('LOWER(email) = ?', email)
          .first
      when 'social_account'
        account = AccountBlock::SocialAccount.find_by(
          email: acc.email.downcase,
          unique_auth_id: acc.unique_auth_id,
          activated: true
        )
      else
        broadcast(:account_not_found)
        return
      end

      unless account.present?
        broadcast(:account_not_found)
        return
      end
      account.invalidate_token

      broadcast(:successful_logout, account)
    end

    def generate_tokens(account_id)
      [
        BuilderJsonWebToken.encode(account_id, 1.day.from_now, token_type: 'login'),
        BuilderJsonWebToken.encode(account_id, 1.year.from_now, token_type: 'refresh')
      ]
    end
  end
end
