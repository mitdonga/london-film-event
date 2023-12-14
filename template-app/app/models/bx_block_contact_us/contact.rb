module BxBlockContactUs
  class Contact < BxBlockContactUs::ApplicationRecord
    self.table_name = :contacts

    belongs_to :account, class_name: "AccountBlock::Account"

    validates :first_name, :last_name, :email, presence: true
    validate :valid_email, if: Proc.new { |c| c.email.present? }
    validates :phone_number, format: { with: /\A\d{10}\z/, message: 'must be a valid 10-digit phone number' }
    # validate :valid_phone_number, if: Proc.new { |c| c.phone_number.present? }

    def self.filter(query_params)
      ContactFilter.new(self, query_params).call
    end

    private

    def valid_email
      validator = AccountBlock::EmailValidation.new(email)
      errors.add(:email, "invalid") if !validator.valid?
    end

    # def valid_phone_number
    #   validator = AccountBlock::PhoneValidation.new(phone_number)
    #   errors.add(:phone_number, "invalid") if !validator.valid?
    # end
  end
end
