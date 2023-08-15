module BxBlockCalendar
  class BookedSlotsController < ApplicationController

    def index
      unless params[:service_provider_id].blank? || params[:date].blank?
        booked_slots = BxBlockAppointmentManagement::BookedSlot.where(
          service_provider_id: params[:service_provider_id],
          booking_date: params[:date]
        )
        render json: BxBlockCalendar::BookedSlotSerializer.new(booked_slots)
      else
        render json: {errors: [
          {availability: 'Date or Service provider Account id is empty'},
        ]}, status: :unprocessable_entity
      end
    end
  end
end
