# frozen_string_literal: true

module BxBlockInvoice
    class InquirySerializer < BuilderBase::BaseSerializer
      attributes :id, :user_id, :service_id, :sub_category_id, :status, :package_sub_total, :addon_sub_total, :extra_cost, :note, :is_bespoke, :updated_at, :created_at, :rejected_by_lf_id, :rejected_by_ca_id, :draft_at, :submitted_at, :partial_approved_at, :approved_at, :hold_at, :rejected_at, :lf_admin_approval_required 
  
      attributes :sub_category_name do |inquiry| 
        inquiry.sub_category&.name
      end
      
      attributes :service_name do |inquiry| 
        serivce_name = inquiry.service.name 
      end

      attributes :event_date do |inquiry| 
        event_date = inquiry.event_date
      end

      attributes :event_name do |inquiry| 
        event_name = inquiry.event_name
      end

      attributes :client_name do |inquiry| 
        client_name = inquiry.client_name
      end

      attributes :meeting_link do |inquiry| 
        company = inquiry.user_company
        company.meeting_link
      end

      attributes :total_price do |inquiry|  # Old
        inquiry.package_sub_total.to_f + inquiry.addon_sub_total.to_f rescue 0
      end

      attributes :base_service_detail do |inquiry, params|
        additional_service = inquiry.base_service
        additional_service.present? ? BxBlockCategories::AdditionalServiceSerializer.new(additional_service, { params: {extra: params[:extra] || false }}).serializable_hash : {}
      end

      attributes :extra_services_detail do |inquiry, params|
        additional_service = inquiry.extra_services
        BxBlockCategories::AdditionalServiceSerializer.new(additional_service, { params: {extra: params[:extra] || false}}).serializable_hash
      end

      attributes :default_coverages, if: proc { |inquiry, params| params[:extra]} do |inquiry|
        inquiry.sub_category.default_coverages
      end
  
      attributes :attachment do |iq|
        iq.attachment.attached? ?
        Rails.application.config.base_url + Rails.application.routes.url_helpers.rails_blob_url(iq.attachment, only_path: true) : ""
      end

      attributes :files do |iq|
        result = []
        iq.files.each do |file|
          result << {name: file.filename, url: Rails.application.config.base_url + Rails.application.routes.url_helpers.rails_blob_url(file, only_path: true), id: file.id} rescue ""
        end
        result
      end

      attributes :cost_summery do |iq|
        iq.get_prices
      end
  
    end
  end
  