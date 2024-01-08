module BxBlockProfile
  class ProfileSerializer < BuilderBase::BaseSerializer
    attributes *[
      :id,
      :first_name,
      :account_type,
      :type,
      :last_name,
      :email,
      :full_phone_number,
      :company_name,
      :location,
    ]

    attribute :company_name do |object|
      object.company.name
    end

    # attributes :photo do |object|
    #   if object.photo.attached?
    #     if Rails.env.development?
    #       Rails.application.routes.url_helpers.rails_blob_path(object.photo, only_path: true)
    #     else
    #       object.photo&.service_url&.split('?')&.first
    #     end
    #   end
    # end

    # attributes :profile_bio do |object|
    #   {
    #     id: object&.profile_bio&.id,
    #     custom_attributes: object&.profile_bio&.custom_attributes,
    #     about_me: object&.profile_bio&.about_me,
    #   }
    # end

    # attributes :qr_code do |object|
    #   {
    #     id: object.qr_code&.id,
    #     qr_code: (Rails.application.routes.url_helpers.rails_blob_path(object.qr_code&.qr_code, only_path: true) if object.qr_code&.qr_code&.attached?)
    #   }
    # end

    # attributes :profile_video do |object|
    #   if object.profile_video.attached?
    #     if Rails.env.development?
    #       ails.application.routes.url_helpers.rails_blob_path(object.profile_video, only_path: true)
    #     else
    #       object.profile_video&.service_url&.split('?')&.first
    #     end
    #   end
    # end

    # attributes :user_profile_data do |object|
    #    obj = {}
    #    custom_user_profile_params =  BxBlockProfile::CustomUserProfileFields.all&.map(&:name).each do |name|
    #    value =   object.user_profile_data.present?  ? object.user_profile_data[name] : ""
    #    obj = obj.merge({"#{name}": value})
    #    end
    #    obj
    # end
  end
end
