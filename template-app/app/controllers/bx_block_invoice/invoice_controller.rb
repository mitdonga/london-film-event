module BxBlockInvoice
  class InvoiceController < BxBlockInvoice::ApplicationController
    skip_before_action :validate_json_web_token, only: [:invoice_pdf, :generate_invoice_pdf]
    before_action :fetch_invoice, only: %i[generate_invoice_pdf invoice_pdf]
    before_action :current_user
    before_action :set_inquiry, only: %i[manage_additional_services]

    def generate_invoice_pdf
      host = "#{request.protocol}#{request.host_with_port}"

      render json: {invoice: "#{host}/#{Rails.application.routes.url_helpers.rails_blob_path(@invoice.invoice_pdf,
        only_path: true)}"}
    end

    def inquiry      
      inquiry = @current_user.inquiries.find_by_id params[:id]
      return render json: { message: "Inquiry not found"}, status: :unprocessable_entity unless inquiry.present?
      
      render json: { inquiry: InquirySerializer.new(inquiry, {params: {extra: true}}).serializable_hash, message: "Success" }, status: :ok
    end

    def inquiries
      inquiries = @current_user.inquiries
      return render json: { inquiries: [], message: "Inquiry not found"}, status: :ok unless inquiries.present?
      render json: { inquiries: InquirySerializer.new(inquiries, {params: {extra: false}}).serializable_hash, message: "#{inquiries.size} inquiries found" }, status: :ok
    end

    def create_inquiry
      inquiry = BxBlockInvoice::Inquiry.new(inquiry_params)
      inquiry.user_id = inquiry.user_id.presence || @current_user.id
      if inquiry.save
        inquiry = BxBlockInvoice::Inquiry.includes(additional_services: [:service, input_values: :input_field]).find(inquiry.id)
        render json: { inquiry: InquirySerializer.new(inquiry, {params: {extra: true}}).serializable_hash, message: "Inquiry successfully created" }, status: :created
      else
        render json: { errors: inquiry.errors.full_messages, message: "Failed to create inquiry, please provide valid details" }, status: :unprocessable_entity
      end
    end

    def manage_additional_services
      service_ids = params[:service_ids].uniq.map {|e| e.to_s.match?(/^\d+$/) ? e.to_i : e} rescue nil
      unless service_ids.present? && service_ids.is_a?(Array) && service_ids.all? { |element| element.is_a?(Numeric) && element > 0 }
        return render json: { message: "service_ids should numeric array"}, status: :unprocessable_entity
      end
      service_ids.delete(@inquiry.service_id)
      current_extra_services_ids = @inquiry.extra_services.pluck(:service_id)

      deleted_services_ids = current_extra_services_ids - service_ids
      newly_added_services_ids = service_ids - current_extra_services_ids

      all_extra_services = @inquiry.all_extra_services

      newly_added_services_ids.each do |service_id|
        additional_service = all_extra_services.find_by(service_id: service_id, inquiry_id: @inquiry.id)
        if additional_service.present?
          additional_service.update(is_valid: true)
        else
          BxBlockCategories::AdditionalService.create(service_id: service_id, inquiry_id: @inquiry.id) if service_id != @inquiry.service_id
        end
      end

      @inquiry.all_extra_services.where(service_id: deleted_services_ids).update_all(is_valid: false)

      render json: { extra_services_detail: BxBlockCategories::AdditionalServiceSerializer.new(@inquiry.extra_services, {params: {extra: true}}) }, status: :ok
    end

    private

    def inquiry_params
      params.require(:inquiry).permit(:service_id, :sub_category_id, :user_id)
    end

    def fetch_invoice
      @invoice = Invoice.find_by(invoice_number: params[:invoice_number].to_s)
      return render json: {errors: [{message: "No invoice found."}]}, status: :not_found unless @invoice
    end

    def set_inquiry
      id = params[:inquiry_id]

      return render json: { message: "Please provide valid inquiry id" }, status: :unprocessable_entity unless id.present?
      
      @inquiry = Inquiry.find_by(id: id, user: @current_user.id)
      return render json: { message: "Inquiry with ID #{id} not found" }, status: :not_found unless @inquiry.present?
    end

  end
end
