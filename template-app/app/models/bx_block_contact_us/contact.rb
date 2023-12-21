module BxBlockContactUs
  class Contact < BxBlockContactUs::ApplicationRecord
    self.table_name = :contacts
    before_save :prepopulated_fields
    belongs_to :account, class_name: "AccountBlock::Account"

    validates :first_name, :last_name, :country_code, :email, presence: true
    validate :valid_email, if: Proc.new { |c| c.email.present? }
    validates :phone_number, format: { with: /\A\d{10}\z/, message: 'must be a valid 10-digit phone number' }
    # validate :valid_phone_number, if: Proc.new { |c| c.phone_number.present? }

    # def self.filter(query_params)
    #   ContactFilter.new(self, query_params).call
    # end

    private

    def valid_email
      validator = AccountBlock::EmailValidation.new(email)
      errors.add(:email, "invalid") if !validator.valid?
    end

    def prepopulated_fields
      self.first_name = self.account.first_name
      self.last_name = self.account.last_name
      self.email = self.account.email
      self.country_code = self.account.country_code
      self.phone_number = self.account.phone_number
    end

    # def valid_phone_number
    #   validator = AccountBlock::PhoneValidation.new(phone_number)
    #   errors.add(:phone_number, "invalid") if !validator.valid?
    # end
  end
end
