module AccountBlock
  class XeroApiService
    @@client_id = Rails.application.config.xero_credentials[:client_id]
    @@client_secret = Rails.application.config.xero_credentials[:client_secret]
    @@xero_tenant_id = Rails.application.config.xero_tenant_id
    @@token = Base64.urlsafe_encode64("#{@@client_id}:#{@@client_secret}")
    
    def initialize
      set_token
    end

    def get_invoices(user_xero_ids, inv_status=nil,  page=1, where_filter)
      return {} if user_xero_ids.blank? || Rails.env == "test"
      # status = inv_status.present? ? "PAID" : inv_status.join(", ")
      status = inv_status.present? ? inv_status : "SUBMITTED,AUTHORISED,PAID,VOIDED"
      # SUBMITTED AUTHORISED PAID DRAFT VOIDED DELETED
      response = HTTParty.get("https://api.xero.com/api.xro/2.0/Invoices",
        query: {
          "ContactIDs" => user_xero_ids,
          "Statuses" => status,
          "page" => page,
          "order" => "UpdatedDateUTC DESC",
          "where" => where_filter
        },
        headers: headers
      )
      JSON.parse(response.body)
    end

    def invoice_pdf(invoice_id)
      response = HTTParty.get(
        "https://api.xero.com/api.xro/2.0/Invoices/#{invoice_id}", 
        headers: {
          "Accept" => "application/pdf",
          "Xero-Tenant-Id" => @@xero_tenant_id,
          "Authorization" => "Bearer #{@token}"
        }
      )
      raise "Invoice with ID #{invoice_id} not found" unless response.code == 200
      file_path = Rails.root.join("tmp", "#{invoice_id}.pdf")
      File.open(file_path, 'wb') do |file|
        file.write(response.parsed_response)
      end
      File.open(file_path, 'r')
    end

    # def contacts
    #   @contacts = @xero_client.accounting_api.get_contacts('').contacts
    # end

    def create_contact(user)
      params = {
        "Contacts": [
          {
            "Name": user.full_name,
            "EmailAddress": user.email,
            "Phones": [
              {
                "PhoneType": "DEFAULT", 
                "PhoneNumber": user.phone_number, 
                "PhoneCountryCode": user.country_code
              }
            ]
          }
        ]
      }
      
      return if Rails.env == "test"
      response = HTTParty.post("https://api.xero.com/api.xro/2.0/Contacts", body: params.to_json, headers: headers)
      result = JSON.parse(response.body)
      user.update(xero_id: result["Contacts"].first["ContactID"]) if result["Contacts"].first["ContactID"].present?
    end

    private

    def set_token
      response = HTTParty.post(
        "https://identity.xero.com/connect/token",
        body: {
          "grant_type" => "client_credentials",
          "scrope" => "accounting.contacts"
        },
        headers: { "Authorization" => "Basic #{@@token}"}
      )
      result = JSON.parse(response.body)
      @token = result["access_token"]
    end

    def headers
      {
        "Accept" => "application/json",
        "Xero-Tenant-Id" => @@xero_tenant_id,
        "Authorization" => "Bearer #{@token}"
      }
    end
  end
end

# AccountBlock::XeroApiService.new.create_contact(user)
  