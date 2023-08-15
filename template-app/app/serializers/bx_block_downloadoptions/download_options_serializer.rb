# frozen_string_literal: true

module BxBlockDownloadoptions
  class DownloadOptionsSerializer < BuilderBase::BaseSerializer
    attribute :profile_photo do |object|
      Rails.application.routes.url_helpers.rails_blob_path(object.image, only_path: true) if object.respond_to?(:image) && object.image.present?
    end

    attribute :front_license_photo do |object|
      if object.license_informations&.front_license_card.present?
        Rails.application.routes.url_helpers.rails_blob_path(object.license_informations.front_license_card,
                                                             only_path: true)
      end
    end

    attribute :back_license_photo do |object|
      if object.license_informations&.back_license_card.present?
        Rails.application.routes.url_helpers.rails_blob_path(object.license_informations.back_license_card,
                                                             only_path: true)
      end
    end

    attribute :front_insurance_photo do |object|
      if object.insurance_informations&.front_insurance_card.present?
        Rails.application.routes.url_helpers.rails_blob_path(object.insurance_informations.front_insurance_card,
                                                             only_path: true)
      end
    end

    attribute :back_insurance_photo do |object|
      if object.insurance_informations&.back_insurance_card.present?
        Rails.application.routes.url_helpers.rails_blob_path(object.insurance_informations.back_insurance_card,
                                                             only_path: true)
      end
    end

    attribute :front_shuttle_vehical do |object|
      if object.vehical_informations&.front_vehical_photo.present?
        Rails.application.routes.url_helpers.rails_blob_path(object.vehical_informations.front_vehical_photo,
                                                             only_path: true)
      end
    end

    attribute :rear_shuttle_vehical do |object|
      if object.vehical_informations&.rear_vehical_photo.present?
        Rails.application.routes.url_helpers.rails_blob_path(object.vehical_informations.rear_vehical_photo,
                                                             only_path: true)
      end
    end
  end
end 
