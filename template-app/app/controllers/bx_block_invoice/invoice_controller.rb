module BxBlockInvoice
  class InvoiceController < BxBlockInvoice::ApplicationController
    skip_before_action :validate_json_web_token, only: [:invoice_pdf, :generate_invoice_pdf]
    before_action :fetch_invoice, only: %i[generate_invoice_pdf invoice_pdf]
    before_action :current_user
    before_action :set_inquiry, only: %i[manage_additional_services save_inquiry calculate_cost upload_attachment submit_inquiry approve_inquiry]
    before_action :check_admin, only: %i[approve_inquiry]

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
  
    def manage_users_inquiries
      if @current_user.type == "ClientAdmin"
        response_data = {
          client_user_inq: @current_user.client_users.map { |cui| cui.inquiries },
          client_admin_inq: @current_user.inquiries
        }
        render json: response_data, serializer: BxBlockInvoice::InquirySerializer
      else
        render json: @current_user.inquiries, each_serializer: BxBlockInvoice::InquirySerializer
      end
    end

    def inquiries
      inquiries = params[:status] == "draft" ? 
                  @current_user.inquiries.where(status: "draft") :
                  params[:status] == "pending" ?
                  @current_user.inquiries.where(status: "pending") :
                  params[:status] == "approved" ?
                  @current_user.inquiries.where(status: "approved") :
                  @current_user.inquiries
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
      unless service_ids.is_a?(Array) && service_ids.all? { |element| element.is_a?(Numeric) && element > 0 }
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

    def save_inquiry
      @inquiry.update(note: params[:note])
      all_values = @inquiry.input_values
      input_values = params[:input_values]
      unless input_values.present? && input_values.is_a?(Array) && input_values.all? { |element| valid_input_value?(element) }
        return render json: { message: "Invalid input_values"}, status: :unprocessable_entity
      end
      errors = []
      input_values.each do |iv|
        input_value, user_input = all_values.find_by_id(iv[:id]), iv[:user_input].to_s.strip
        if input_value.present?
          unless input_value.update(user_input: user_input)
            errors << input_value.errors.full_messages.first + " ID #{iv[:id]}"
          end
        elsif !input_value.present?
          errors << "Input value with ID #{iv[:id]} not present"
        end
      end
      return render json: { message: "Updated user inputs, got some errors", errors: errors }, status: :ok if errors.present?
      render json: { message: "User inputs successfully updated", errors: []}, status: :ok
    end

    def calculate_cost
      all_values, errors = @inquiry.input_values, []
      all_values.each do |input_value|
        input_value.calculate_cost
        if input_value.errors.full_messages.present?
          data = {}
          data["input_value_id"] = input_value.id
          data["name"] = input_value.current_input_field.name
          data["error"] = input_value.errors.full_messages.first
          errors << data
        end
      end
      return render json: {message: "Something went wrong!",errors: errors}, status: :unprocessable_entity if errors.present?
      @inquiry.calculate_addon_cost
      render json: { inquiry: InquirySerializer.new(@inquiry, {params: {extra: true}}).serializable_hash, message: "Success" }, status: :ok
    end

    def upload_attachment
      if params[:attachment].present?
        @inquiry.attachment.attach(params[:attachment])
        url = Rails.application.config.base_url + Rails.application.routes.url_helpers.rails_blob_url(@inquiry.attachment, only_path: true)
        render json: {url: url, message: "File successfully uploaded"}, status: :ok
      else
        @inquiry.attachment.purge
        render json: {url: "",message: "File successfully removed"}, status: :ok
      end
    end

    def submit_inquiry
      return render json: {message: "Inquiry already submitted"}, status: :unprocessable_entity if @inquiry.status != "draft"
      all_values, errors = @inquiry.input_values, []
      all_values.each do |input_value|
        input_value.calculate_cost
        if input_value.errors.full_messages.present?
          data = {}
          data["input_value_id"] = input_value.id
          data["name"] = input_value.current_input_field.name
          data["error"] = input_value.errors.full_messages.first
          errors << data
        end
      end
      if errors.present?
        if errors.any? { |error| error["error"].include?("Speak to expert") }
          send_email_to_lf
        end
        return render json: {message: "Invalid data entered",errors: errors}, status: :unprocessable_entity
      end
      @inquiry.update(status: "pending")
      InquiryMailer.send_inquiry_details_to(@inquiry.id).deliver
      render json: { inquiry: InquirySerializer.new(@inquiry, {params: {extra: true}}).serializable_hash, message: "Inquiry successfully submitted" }, status: :ok
    end

    def approve_inquiry
      if @inquiry.status == "pending"
        if @inquiry.update(status: "approved", approved_by_client_admin: @current_user)
          render json: {inquiry: InquirySerializer.new(@inquiry, {params: {extra: true}}).serializable_hash, message: "Success"}, status: :ok
        else
          render json: {message: "Unable to approve inquiry", errors: @inquiry.errors.full_messages}, status: :unprocessable_entity
        end
      else
        render json: {message: "Inquiry is not in pending state"}, status: :unprocessable_entity
      end
    end

    def user_invoices
      # status = DRAFT | AUTHORISED | PAID
      invoice_status = params[:status]
      page = params[:page]
      invoices = AccountBlock::XeroApiService.new.get_invoices(@current_user, invoice_status, page)
      render json: {invoices: invoices, message: "Success"}, status: :ok
    rescue Exception => e
      render json: {message: e.message}, status: :unprocessable_entity
    end

    private

    def send_email_to_lf
      BxBlockContactUs::ContactMailer.date_mail_from_user(@inquiry.user).deliver_now
    end

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

    def valid_input_value?(hash)
      return false unless hash.key?(:id) && hash.key?(:user_input)
      true
    rescue
      false
    end

    def check_admin
      return render json: { errors: ["You're unauthorized to perform this action", "Only client admin can perform this action"] }, status: :unauthorized unless @current_user.type == "ClientAdmin"
    end

  end
end
