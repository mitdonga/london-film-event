module BxBlockContactUs
  class Contact < BxBlockContactUs::ApplicationRecord
    self.table_name = :contacts
    before_save :prepopulated_fields
    belongs_to :account, class_name: "AccountBlock::Account"
    has_one_attached :file
    before_save :filter_mobile_number

    validates :details, length: { maximum: 1000 }
    validates :first_name, :last_name, :email, presence: true
    validate :valid_email, if: Proc.new { |c| c.email.present? }
    # validates :phone_number, format: { with: /\A\d{10}\z/, message: 'must be a valid 10-digit phone number' }
    # validate :valid_phone_number, if: Proc.new { |c| c.phone_number.present? }

    # def self.filter(query_params)
    #   ContactFilter.new(self, query_params).call
    # end

    private

    def filter_mobile_number
      phone = Phonelib.parse("#{self.full_mobile_number}")
      self.country_code = phone.country_code
      self.phone_number = phone.raw_national
    end

    def valid_email
      validator = AccountBlock::EmailValidation.new(email)
      errors.add(:email, "invalid") if !validator.valid?
    end

    def prepopulated_fields
      self.email = self.account.email
    end

    # def valid_phone_number
    #   validator = AccountBlock::PhoneValidation.new(phone_number)
    #   errors.add(:phone_number, "invalid") if !validator.valid?
    # end
  end
end
