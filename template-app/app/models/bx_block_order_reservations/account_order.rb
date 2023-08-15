module BxBlockOrderReservations
  class AccountOrder < BuilderBase::ApplicationRecord
    self.table_name = :account_orders

    belongs_to :account, class_name: "AccountBlock::Account"
    belongs_to :reservation_service, class_name: "BxBlockOrderReservations::ReservationService"

    enum order_status: ["pending", "placed", "cancelled"]


    after_save :update_total_price, :update_booking_status

    def update_total_price
      calculated_price = (self.quantity * self.reservation_service.price.to_f).to_f if self.quantity.present? && self.reservation_service.present?
      self.update_columns(total_price: calculated_price, order_status: "placed") if calculated_price.present?
    end

    def update_booking_status
      self.reservation_service.update_column(:booking_status, "booked") if self.reservation_service.present?
    end

  end
end