module BxBlockOrderReservations
  class ReservationServiceSerializer < BuilderBase::BaseSerializer

    attributes *[ 
      :id,  
      :price, 
      :state, 
      :full_address, 
      :city, 
      :reservation_date, 
      :zip_code, 
      :created_at, 
      :updated_at, 
      :booking_status,
      :slot_start_time,
      :slot_end_time
    ]

    attribute :image do |object|
      if object.image.attached?
        if Rails.env.production?
          object.image&.service_url
        else
          Rails.application.routes.url_helpers.rails_blob_path(object.image, only_path: true)
        end
      end
    end

  end
end
