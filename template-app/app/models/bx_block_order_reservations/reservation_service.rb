module BxBlockOrderReservations
  class ReservationService < BuilderBase::ApplicationRecord
    self.table_name = :reservation_services

    validates :city, :full_address, :reservation_date, :state, :zip_code, :service_name, :booking_status, :slot_start_time, :slot_end_time, :price, presence: true

    enum booking_status: ["availabile", "booked"]

    has_one_attached :image, dependent: :destroy
  end
end
