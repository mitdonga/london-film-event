module AccountBlock
  class Account < AccountBlock::ApplicationRecord
    # ActiveSupport.run_load_hooks(:account, self)
    self.table_name = :accounts

    include Wisper::Publisher
    validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "Please enter valid email" }, uniqueness: { case_sensitive: false, message: "Account already exist with this email" }
    validates :account_type, :first_name, :last_name, :full_phone_number, :phone_number, :company_id, presence: true
    validates :phone_number, :country_code, presence: true, on: [:create]

    has_secure_password
    has_one_attached :profile_picture
    before_validation :parse_full_phone_number, on: [:create]
    before_validation :set_password, on: :create
    before_create :generate_api_key
    after_create :create_xero_contact
    after_create :send_email
    has_one :blacklist_user, class_name: "AccountBlock::BlackListUser", dependent: :destroy
    belongs_to :company, class_name: "BxBlockInvoice::Company"
    after_save :set_black_listed_user
    before_save :send_welcome_user_email, if: :activated_changed?

    has_many :notifications, class_name: "BxBlockNotifications::Notification"
    has_many :email_notifications, through: :notifications
    
    has_many :inquiries, class_name: "BxBlockInvoice::Inquiry", foreign_key: "user_id"

    enum status: %i[regular suspended deleted]
    enum account_type: %i[venue corporate]

    scope :active, -> { where(activated: true) }
    scope :existing_accounts, -> { where(status: ["regular", "suspended"]) }

    def generate_password
      pass = "#{email.to_s.slice(0,4)}#{phone_number.to_s.slice(0,4)}"
      "@Lf#{Base64.urlsafe_encode64(pass, padding: false)}23#"
    end

    def full_name
      "#{first_name} #{last_name}"
    end

    def available_services
      company.available_services
    end

    def available_sub_categories
      company.available_sub_categories
    end

    def invalidate_token
      update(token_expires_at: Time.current)
      last_visit_date = Time.parse("#{self&.last_visit_at}")
      token_expires_date = Time.parse("#{self&.token_expires_at}")

      if (last_visit_date && token_expires_date).present?
        time_duration_seconds = token_expires_date - last_visit_date
        hours, remainder = time_duration_seconds.divmod(3600)
        minutes, seconds = remainder.divmod(60)
        update(session_duration: "#{hours} hours, #{minutes} minutes")
      end
    end

    def is_email_enabled?
      email_enable?
    end

    def is_admin?
      self.type == "ClientAdmin"
    end

    private

    def set_password
      self.password = self.password_confirmation = self.generate_password
    end

    def create_xero_contact
      AccountBlock::XeroApiService.new.create_contact(self)
    rescue Exception => e
      puts e
    end

    def send_email
      EmailValidationMailer
            .with(account: self, host: "#{Rails.application.config.base_url}")
            .activation_email.deliver_later
      ManageAccountMailer.send_welcome_mail_to_admins(self.id).deliver_later
    end 

    def send_welcome_user_email
      ManageAccountMailer.send_welcome_mail_to_user(self.id).deliver_later if activated
    end

    def parse_full_phone_number
      # phone = Phonelib.parse("#{self.full_phone_number}")
      # self.full_phone_number = phone.sanitized
      # self.country_code = phone.country_code
      # self.phone_number = phone.raw_national
      self.full_phone_number = "+#{self.country_code.to_s} #{self.phone_number}"
      self.country_code = self.country_code.to_i

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
