module BxBlockCustomForms
  class CustomFormSerializer < BuilderBase::BaseSerializer
    attributes *[
      :first_name,
      :last_name,
      :phone_number,
      :organization,
      :team_name,
      :i_am,
      :gender, 
      :email, 
      :address, 
      :country, 
      :state, 
      :city,
      :stars_rating
    ]

    attribute :file do |object, params|
      host = params[:host] || ''
      { url: (host + Rails.application.routes.url_helpers.rails_blob_path(object.file, only_path: true)),
        content_type: "#{object.file.blob.content_type}",
        file_name: "#{object.file.blob.filename}"
      } if object.file.present?
    end
  end
end