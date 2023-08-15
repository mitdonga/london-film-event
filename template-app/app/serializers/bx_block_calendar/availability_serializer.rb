module BxBlockCalendar
  class AvailabilitySerializer< BuilderBase::BaseSerializer

    attributes *[:service_provider_id,
                 :start_time,
                 :end_time,
                 :unavailable_start_time,
                 :unavailable_end_time,
                 :availability_date,
    ]
    attribute :booked_slots do |object, params|
      BxBlockAppointmentManagement::BookedSlot.where(
        service_provider: object.service_provider
      ).where(
        booking_date: (Date.parse(params[:date]))
      ).map{|slot| {
        start_time: slot.start_time,
        end_time: slot.end_time,
        booking_date: slot.booking_date
      }} if params[:date].present?
    end
  end
end
