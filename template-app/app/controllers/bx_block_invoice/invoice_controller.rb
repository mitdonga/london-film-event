module BxBlockInvoice
  class InvoiceController < BxBlockInvoice::ApplicationController
    skip_before_action :validate_json_web_token, only: [:invoice_pdf, :generate_invoice_pdf]
    before_action :fetch_invoice, only: %i[generate_invoice_pdf invoice_pdf]
    before_action :current_user

    def generate_invoice_pdf
      host = "#{request.protocol}#{request.host_with_port}"

      render json: {invoice: "#{host}/#{Rails.application.routes.url_helpers.rails_blob_path(@invoice.invoice_pdf,
        only_path: true)}"}
    end

    def inquiry
      return render json: { message: "Provide valid inquiry"}, status: :unprocessable_entity unless params[:id]
      
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

    private

    def inquiry_params
      params.require(:inquiry).permit(:service_id, :sub_category_id, :user_id)
    end

    def fetch_invoice
      @invoice = Invoice.find_by(invoice_number: params[:invoice_number].to_s)
      return render json: {errors: [{message: "No invoice found."}]}, status: :not_found unless @invoice
    end
  end
end
