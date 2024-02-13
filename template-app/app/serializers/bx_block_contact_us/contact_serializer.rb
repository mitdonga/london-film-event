module BxBlockContactUs
  class ContactSerializer < BuilderBase::BaseSerializer
    attributes *[
        :first_name,
        :last_name,
        :email,
        :country_code,
        :phone_number,
        :full_mobile_number,
        :subject,
        :details,
    ]

    attribute :file do |obj|
      obj.file.attached? ?
      Rails.application.config.base_url + Rails.application.routes.url_helpers.rails_blob_url(obj.file, only_path: true) : "No File Attached"
    end

    # attribute :user do |object|
    #   user_for object
    # end

    # class << self
    #   private

    #   def user_for(object)
    #     "#{object.account.first_name} #{object.account.last_name}"
    #   end
    # end
  end
end
