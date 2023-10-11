module AccountBlock
  class Account < AccountBlock::ApplicationRecord
    # ActiveSupport.run_load_hooks(:account, self)
    self.table_name = :accounts

    include Wisper::Publisher

    validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "Please enter valid email" }, uniqueness: { case_sensitive: false, message: "Account already exist with this email" }
    validates :account_type, :first_name, :last_name, :full_phone_number, presence: true
    validates :full_phone_number, uniqueness: { message: "Account already exist with this phone number" }, presence: true

    has_secure_password
    before_validation :parse_full_phone_number
    before_create :generate_api_key
    after_save :send_email
    has_one :blacklist_user, class_name: "AccountBlock::BlackListUser", dependent: :destroy
    belongs_to :company, class_name: "BxBlockInvoice::Company"
    after_save :set_black_listed_user

    enum status: %i[regular suspended deleted]
    enum account_type: %i[venue corporate]

    scope :active, -> { where(activated: true) }
    scope :existing_accounts, -> { where(status: ["regular", "suspended"]) }

    private

    def send_email
      EmailValidationMailer
            .with(account: self, host: "#{Rails.application.config.base_url}")
            .activation_email.deliver
    end 

    def parse_full_phone_number
      phone = Phonelib.parse("#{self.country_code}#{self.phone_number}")
      self.full_phone_number = phone.sanitized
      self.country_code = phone.country_code
      self.phone_number = phone.raw_national
    end

    def valid_phone_number
      unless Phonelib.valid?(full_phone_number)
        errors.add(:full_phone_number, "Invalid or Unrecognized Phone Number")
      end
    end

    def generate_api_key
      loop do
        @token = SecureRandom.base64.tr("+/=", "Qrt")
        break @token unless Account.exists?(unique_auth_id: @token)
      end
      self.unique_auth_id = @token
    end

    def set_black_listed_user
      if is_blacklisted_previously_changed?
        if is_blacklisted
          AccountBlock::BlackListUser.create(account_id: id)
        else
          blacklist_user.destroy
        end
      end
    end
  end
end
