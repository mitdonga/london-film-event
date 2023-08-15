module BxBlockCalendar
  class AvailabilitiesController < ApplicationController

    include BuilderJsonWebToken::JsonWebTokenValidation

    before_action :check_user_role, only: %i(update_availability_time)
    before_action :get_service_provider, only: %i(get_booked_time_slots)

    def update_availability_time
      slot = BxBlockAppointmentManagement::Availability.new(
        slot_detail.merge({ service_provider_id: @service_provider.id })
      )
      if slot.save
        render json: BxBlockCalendar::AvailabilitySerializer.new(slot, meta: {
          message: 'Your slot created for the day'
        }).serializable_hash, status: :created
      else
        render json: { errors: format_activerecord_errors(slot.errors) },
               status: :unprocessable_entity
      end
    end

    private
    def slot_detail
      params.require(:availability).permit(
        :availability_date, :start_time, :end_time, :unavailable_start_time, :unavailable_end_time
      )
    end

    def check_user_role
      @service_provider = AccountBlock::Account.find_by(id: @token.id)
      render json: {
        errors: 'Permission denied'
      } and return unless is_merchant?#@service_provider.is_merchant?
    end

    def format_activerecord_errors(errors)
      result = []
      errors.each do |attribute, error|
        result << { attribute => error }
      end
      result
    end

    def is_merchant?
      role = BxBlockRolesPermissions::Role.find_by(id: @service_provider.role_id)
      return false unless role
      role.name == 'Merchant'
    end
  end
end
