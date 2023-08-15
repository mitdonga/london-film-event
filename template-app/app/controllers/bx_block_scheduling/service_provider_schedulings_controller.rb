module BxBlockScheduling
  class ServiceProviderSchedulingsController < ApplicationController
    before_action :find_service_provider, only: [:get_sp_details]

    def get_sp_details
      render json: {
        errors: 'Please enter the date'
      } and return unless params[:availability_date].present?

      availability = BxBlockAppointmentManagement::Availability.where(
        service_provider_id: @service_provider.id
      ).filter_by_date(params[:availability_date])

      render json: {
        errors: 'Service provider does not set the availability for the day'
      } and return  unless availability.present?

      render json: BxBlockCalendar::AvailabilitySerializer.new(
        availability, params: { date: params[:availability_date] }
      )
    end

    private

    def find_service_provider
      render json: {
        errors: 'Invalid Service provider'
      } and return unless params[:service_provider_id].present?
      @service_provider = AccountBlock::Account.find(params[:service_provider_id])
    end
  end
end
