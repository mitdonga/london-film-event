module AccountBlock
  class EmailValidation
    include ActiveModel::Validations

    attr_reader :email

    class << self
      def regex
        /[^@]+@\S+[.]\S+/
      end

      def regex_string
        regex.to_s.sub("(?-mix:", "").delete_suffix(")")
      end
    end

    validate :validate_email_domain

    validates :email, format: {
      with: regex,
      multiline: true
    }

    def initialize(email)
      @email = email
    end

    private

    def validate_email_domain
      return if email_domain == 'gmail.com'
      errors[:email] << "You've entered an email from an external domain. Please confirm this is correct before saving."
    end

    def email_domain
      email.to_s.split('@').last
    end
  end
end
