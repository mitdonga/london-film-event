module BxBlockInvoice
  class InvoiceController < BxBlockInvoice::ApplicationController
    skip_before_action :validate_json_web_token, only: [:generate_invoice_pdf]
    before_action :fetch_invoice, only: %i[generate_invoice_pdf]
    before_action :current_user
    before_action :set_inquiry, only: %i[manage_additional_services save_inquiry calculate_cost upload_attachment submit_inquiry approve_inquiry change_inquiry_sub_category delete_inquiry draft_inquiry reject_inquiry]
    before_action :check_admin, only: %i[approve_inquiry delete_inquiry delete_user_inquiries reject_inquiry]

    def generate_invoice_pdf
      host = "#{request.protocol}#{request.host_with_port}"

      render json: {invoice: "#{host}/#{Rails.application.routes.url_helpers.rails_blob_path(@invoice.invoice_pdf,
        only_path: true)}"}
    end

    def inquiry
      inquiry = user_inquiries.find_by_id params[:id]
      return render json: { message: "Inquiry not found"}, status: :unprocessable_entity unless inquiry.present?
      
      render json: { inquiry: InquirySerializer.new(inquiry, {params: {extra: true}}).serializable_hash, message: "Success" }, status: :ok
    end

    def delete_inquiry
      @inquiry.destroy
      render json: {message: "Inquiry successfully deleted"}, status: :ok
    end

    def delete_user_inquiries
      user = AccountBlock::Account.find_by(id: params[:user_id])
      if user.present?
        user.inquiries.destroy_all
        return render json: {message: "Deleted all inquiries"}, status: :ok
      end
      render json: {message: "User not found"}, status: :unprocessable_entity
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
                  user_inquiries.where(status: "draft") :
                  params[:status] == "rejected" ? 
                  user_inquiries.where(status: "rejected") :
                  params[:status] == "hold" ? 
                  user_inquiries.where(status: "hold") :
                  params[:status] == "pending" ?
                  user_inquiries.where("(status = ? AND lf_admin_approval_required = false) OR (status = ? AND lf_admin_approval_required = true) OR (status = ? AND is_bespoke = true)", 2, 3, 3) :
                  params[:status] == "approved" ?
                  user_inquiries.where(status: "approved") :
                  user_inquiries.where.not(status: "unsaved")
      inquiries = params[:filter_by].present? ? inquiries.where("created_at >= ?", filter_by_params.to_time) : inquiries
      return render json: { inquiries: [], message: "Inquiry not found"}, status: :ok unless inquiries.present?
      render json: { inquiries: InquirySerializer.new(inquiries.order(created_at: :desc), {params: {extra: false}}).serializable_hash, message: "#{inquiries.size} inquiries found" }, status: :ok
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
      errors, event_start_time, event_end_time = [], nil, nil
      input_values.each do |iv|
        input_value, user_input = all_values.find_by_id(iv[:id]), iv[:user_input].to_s.strip
        if input_value.present?
          unless input_value.update(user_input: user_input)
            errors << input_value.errors.full_messages.first + " ID #{iv[:id]}"
          end
          event_start_time = user_input if input_value.current_input_field.name.downcase.include?("event start time")
          event_end_time = user_input if input_value.current_input_field.name.downcase.include?("event end time")
        elsif !input_value.present?
          errors << "Input value with ID #{iv[:id]} not present"
        end
      end
      if event_start_time.present? && event_end_time.present?
        begin
          event_start_time = Time.parse(event_start_time)
          event_end_time = Time.parse(event_end_time)
          diff = (event_end_time - event_start_time)/3600
          duration = @inquiry.sub_category.duration
          errors << "Event duration is greater than #{duration} hours for #{@inquiry.sub_category.name} event" if diff > duration
        rescue Exception => e
          puts "event_start_time: #{event_start_time} | event_end_time: #{event_end_time}"
          puts e
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
      if params[:files].present?
        @inquiry.files.attach(params[:files])
      end
      if params[:remove_file_ids].present?
        @inquiry.files.attachments.find(params[:remove_file_ids]).each do |file|
          file.purge
        end
      end
      render json: {inquiry: InquirySerializer.new(@inquiry).serializable_hash, message: "Success"}, status: :ok
    rescue Exception => e
      render json: {message: "Something went wrong", error: e.message}, status: :unprocessable_entity
    end

    def submit_inquiry
      new_status = params[:new_status] == "pending" ? "pending" : "draft"
      return render json: {message: "Can't draft this inquiry"}, status: :unprocessable_entity if new_status == "draft" && !["unsaved", "draft"].include?(@inquiry.status)
      return render json: {message: "Can't submit this inquiry"}, status: :unprocessable_entity if new_status == "pending" && !["unsaved", "draft"].include?(@inquiry.status)
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
        # if errors.any? { |error| error["error"].include?("Speak to expert") }
        #   send_email_to_lf
        # end
        return render json: {message: "Invalid data entered",errors: errors}, status: :unprocessable_entity
      end
      @inquiry.update(status: new_status)
      InquiryMailer.send_inquiry_details_to(@inquiry.id, @inquiry.is_bespoke).deliver if new_status == "pending"
      render json: { inquiry: InquirySerializer.new(@inquiry, {params: {extra: true}}).serializable_hash, message: "Inquiry successfully #{new_status == "pending" ? 'submitted' : 'draft'}" }, status: :ok
    end

    def approve_inquiry
      if ["hold", "rejected", "pending", "partial_approved"].include?(@inquiry.status)
        if @inquiry.update(status: "approved", approved_by_client_admin: @current_user)
          render json: {inquiry: InquirySerializer.new(@inquiry, {params: {extra: true}}).serializable_hash, message: "Success"}, status: :ok
        else
          render json: {message: "Unable to approve inquiry", errors: @inquiry.errors.full_messages}, status: :unprocessable_entity
        end
      else
        render json: {message: "Unable to approve inquiry"}, status: :unprocessable_entity
      end
    end

    def reject_inquiry
      if ["hold", "pending", "approved", "partial_approved"].include?(@inquiry.status)
        if @inquiry.update(status: "rejected", rejected_by_ca: @current_user, status_description: params[:status_description])
          render json: {inquiry: InquirySerializer.new(@inquiry, {params: {extra: true}}).serializable_hash, message: "Success"}, status: :ok
        else
          render json: {message: "Unable to reject inquiry", errors: @inquiry.errors.full_messages}, status: :unprocessable_entity
        end
      else
        render json: {message: "Unable to reject inquiry"}, status: :unprocessable_entity
      end
    end

    def user_invoices
      # status = DRAFT | AUTHORISED | PAID
      invoice_status, page = params[:status], params[:page]
      start_date = params[:start_date].present? ? params[:start_date] : filter_by_params
      end_date = params[:end_date]

      where_filter = set_invoice_filter(start_date: start_date, end_date: end_date)
      xero_ids = @current_user_company.accounts.pluck(:xero_id).filter {|e| e.present? && e.size > 5}.join(",")
      invoices = AccountBlock::XeroApiService.new.get_invoices(xero_ids, invoice_status, page, where_filter)
      render json: {invoices: invoices, message: "Success"}, status: :ok
    rescue Exception => e
      render json: {message: e.message}, status: :unprocessable_entity
    end

    def invoice_pdf
      invoice_id = params[:invoice_uid]
      return render json: {message: "Invoice ID required"}, status: :unprocessable_entity unless invoice_id.present?
      pdf = AccountBlock::XeroApiService.new.invoice_pdf(invoice_id)
      send_file(
        pdf.path,
        filename: "#{invoice_id}.pdf",
        type: "application/pdf",
        disposition: "attachment"
      )
    rescue Exception => e
      render json: {message: "Failed to download invoice PDF", error: e.message}, status: :unprocessable_entity
    end

    def change_inquiry_sub_category
      days_coverage = @inquiry.days_coverage
      current_service = @inquiry.service
      messages = []
      sub_category = @inquiry.sub_category&.name
      new_sub_category = nil
      target_sub_category = nil
      if days_coverage.present? && days_coverage > 0
        if days_coverage > 1 && !@inquiry.is_bespoke
          new_sub_category, target_sub_category = @inquiry.service.sub_categories.find_by("sub_categories.name ilike ?", "%bespoke%"), "Bespoke Request"
        elsif days_coverage == 1 && !@inquiry.is_full_day
          new_sub_category, target_sub_category = @inquiry.service.sub_categories.find_by("name ilike ?", "%full%"), "Full Day"
        elsif days_coverage < 1 && !@inquiry.is_half_day
          new_sub_category, target_sub_category = @inquiry.service.sub_categories.find_by("name ilike ?", "%half%"), "Half Day"
        end
        if new_sub_category.present?
          message = "Because you have selected '#{days_coverage < 1 ? days_coverage : days_coverage.to_i} #{days_coverage > 1 ? "days" : "day"}', we need to re-direct you to the form for #{current_service.name} | #{new_sub_category.name}. Please confirm this is what you require."
          return render json: {message: message}, status: :ok if params[:only_message].present?
          new_inquiry = BxBlockInvoice::Inquiry.new(user: @current_user, service: @inquiry.service, sub_category: new_sub_category)
          if new_inquiry.save
            @inquiry.input_values.joins(:input_field).where("input_fields.section in (?)", [0, 2]).each do |iv|
              input_value = new_inquiry.input_values.find_by(input_field_id: iv.input_field_id) rescue nil
              input_value.update(user_input: iv.user_input) if input_value.present?
            end
            new_inquiry.update(status: @inquiry.status)
            @inquiry.destroy
            return render json: {inquiry: InquirySerializer.new(new_inquiry, {params: {extra: true}}).serializable_hash, message: messages}, status: :ok
          else
            messages << new_inquiry.full_messages
          end
        elsif target_sub_category.present?
          return render json: {message: "#{target_sub_category} package not available", messages: messages}, status: :unprocessable_entity
        end
        return render json: {message: "No need to change package duration"}, status: :ok
      else
        render json: {message: "How many days coverage? option not selected for this inquiry"}, status: :unprocessable_entity
      end
    end

    private

    def set_invoice_filter(start_date: nil, end_date: nil)
      arr, st_dt, ed_dt = [], start_date&.to_date, end_date&.to_date
      arr << "Date >= DateTime(#{st_dt.year}, #{"%02d" % st_dt.month}, #{"%02d" % st_dt.day})" if st_dt.present?
      arr << "Date <= DateTime(#{ed_dt.year}, #{"%02d" % ed_dt.month}, #{"%02d" % ed_dt.day})" if ed_dt.present?
      arr.present? ? arr.join(" && ") : ""
    end

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
      
      @inquiry = user_inquiries.find_by(id: id)
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

    def filter_by_params
      params[:filter_by] == "week" ?
        Date.today - 1.week :
      params[:filter_by] == "month" ?
        Date.today - 1.month :
        Date.today - 1.day
    end

    def user_inquiries
      if @current_user.is_admin?
        @current_user_company.company_inquiries
      else
        Inquiry.where(user_id: @current_user)
      end
    end

  end
end
