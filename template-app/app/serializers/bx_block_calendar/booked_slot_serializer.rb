module BxBlockCalendar
  class BookedSlotSerializer < BuilderBase::BaseSerializer
    attributes :id, :start_time, :end_time

    attributes :viewable_slot do |object|
      "#{object.start_time} - #{object.end_time}"
    end
  end
end
