module AccountBlock
  class XeroApiService
    @@client_id = Rails.application.config.xero_credentials[:client_id]
    @@client_secret = Rails.application.config.xero_credentials[:client_secret]
    @@xero_tenant_id = Rails.application.config.xero_tenant_id
    @@token = Base64.urlsafe_encode64("#{@@client_id}:#{@@client_secret}")
    
    def initialize
      set_token
    end

    def get_invoices(user, inv_status=nil,  page=1)
      # return [] unless user.xero_id.present?
      # status = inv_status.nil? ? "" : inv_status.join(", ")

      response = HTTParty.get(
        "https://api.xero.com/api.xro/2.0/Invoices",
        body: {
          "ContactIDs" => user.xero_id,
          "page" => page
        },
        headers: headers
      )

      result = JSON.parse(response.body)
      # result[""]
      # @invoices = user.xero_id.present? && Rails.env != "test" ? @xero_client.accounting_api.get_invoices(XERO_TENANT_ID, opts).invoices : []
    end

    def invoice_pdf(invoice_id)
      @xero_client.accounting_api.get_invoice_as_pdf(XERO_TENANT_ID, invoice_id)
    end

    # def contacts
    #   @contacts = @xero_client.accounting_api.get_contacts('').contacts
    # end

    def create_contact(user)
      user_phone_number = user.phone_number
      phone = { 
        phone_number: user_phone_number,
        phone_type: "DEFAULT"
      }
      phones = []
      phones << phone

      contact = {
        name: user.full_name,
        # name: "#{user.full_name} - #{user.id}",
        email_address: user.email,
        phones: phones
      }  

      contacts = {  
        contacts: [contact]
      }
      application_enviroment = Rails.env
      if application_enviroment == "test"
        return
      end
      response = @xero_client.accounting_api.create_contacts(XERO_TENANT_ID, contacts)
      user.update(xero_id: response.contacts.first.contact_id)
    end

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
  