module AccountBlock
  class AccountSerializer < BuilderBase::BaseSerializer
    attributes(:activated, :location, :country_code, :email, :first_name, :full_phone_number, :country_code, :phone_number, :last_name, :phone_number, :type, :account_type, :client_admin_id, :device_id, :unique_auth_id, :should_reset_password)

    # attribute :country_code do |object|
    #   country_code_for object
    # end

    # attribute :phone_number do |object|
    #   phone_number_for object
    # end

    attribute :company do |object|
      object.company
    end

    attribute :client_admin do |object|
      ca = object.client_admin_id ? object.client_admin : nil
      ca.present? ? { name: ca.full_name, country_code: ca.country_code, phone_number: ca.phone_number, email: ca.email } : nil
    end

    # class << self
    #   private

    #   def country_code_for(object)
    #     return nil unless Phonelib.valid?(object.full_phone_number)
    #     Phonelib.parse(object.full_phone_number).country_code
    #   end

    #   def phone_number_for(object)
    #     return nil unless Phonelib.valid?(object.full_phone_number)
    #     Phonelib.parse(object.full_phone_number).raw_national
    #   end
    # end
  end
end
