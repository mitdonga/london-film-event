module BxBlockOrderReservations
  class ReservationServicesController < ApplicationController

    def index
      products = BxBlockOrderReservations::ReservationService.all
      render json: BxBlockOrderReservations::ReservationServiceSerializer.new(products).serializable_hash
    end

  end
end