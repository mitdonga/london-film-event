# frozen_string_literal: true

module BxBlockInvoice
    class InquirySerializer < BuilderBase::BaseSerializer
      attributes :id, :user_id, :service_id, :sub_category_id, :status
  
      attributes :base_service_detail do |inquiry, params|
        return [] unless inquiry.base_service.present?
        additional_service = inquiry.base_service
        BxBlockCategories::AdditionalServiceSerializer.new(additional_service, { params: {extra: params[:extra] || false }}).serializable_hash
      end

      attributes :extra_services_detail do |inquiry, params|
        additional_service = inquiry.extra_services
        BxBlockCategories::AdditionalServiceSerializer.new(additional_service, { params: {extra: params[:extra] || false }}).serializable_hash
      end
  
      attributes :attachment do |iq|
        iq.attachment.attached? ?
        Rails.application.config.base_url + Rails.application.routes.url_helpers.rails_blob_url(iq.attachment, only_path: true) : ""
      end
  
    end
  end
  