module BxBlockOrderReservations
  class AccountOrderSerializer < BuilderBase::BaseSerializer
    attributes :id, :order_status, :total_price , :account, :placed_date_time, :created_at, :updated_at, :reservation_service

    attribute :reservation_service_image do |object|
      if object.reservation_service.present? && object.reservation_service.image.attached?
        if Rails.env.production?
          object.reservation_service.image&.service_url 
        else
          Rails.application.routes.url_helpers.rails_blob_path(object.reservation_service.image, only_path: true)
        end
      end
    end

  end
end
