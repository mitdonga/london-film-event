module AccountBlock
  class AccountSerializer < BuilderBase::BaseSerializer
    attributes(:activated, :location, :country_code, :email, :first_name, :full_phone_number, :country_code, :phone_number, :last_name, :phone_number, :type, :job_title, :account_type, :email_enable, :client_admin_id, :device_id, :unique_auth_id, :should_reset_password)

    # attribute :country_code do |object|
    #   country_code_for object
    # end

    # attribute :phone_number do |object|
    #   phone_number_for object
    # end

    attribute :profile_picture do |obj|
      obj.profile_picture.attached? ?
      Rails.application.config.base_url + Rails.application.routes.url_helpers.rails_blob_url(obj.profile_picture, only_path: true) : "No File Attached"
    end

    attribute :company do |object|
      object.company
    end

    attribute :profile_picture do |obj|
      obj.profile_picture.attached? ?
      Rails.application.config.base_url + Rails.application.routes.url_helpers.rails_blob_url(obj.profile_picture, only_path: true) : "No File Attached"
    end

    attribute :company_logo do |obj|
      obj.company.logo.attached? ?
      Rails.application.config.base_url + Rails.application.routes.url_helpers.rails_blob_url(obj.company.logo, only_path: true) : nil
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
