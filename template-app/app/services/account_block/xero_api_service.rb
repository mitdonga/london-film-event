module AccountBlock
  class XeroApiService

    CREDENTIALS = Rails.application.config.xero_credentials
    @@xero_client = XeroRuby::ApiClient.new(credentials: CREDENTIALS)

    def initialize
      update_token 
    end

    def invoices
      @invoices = @@xero_client.accounting_api.get_invoices('').invoices
    end

    def contacts
      @contacts = @@xero_client.accounting_api.get_contacts('').contacts
    end

    def create_contact(user)
      phone = { 
        phone_number: user.phone_number,
        phone_type: "DEFAULT"
      }
      phones = []
      phones << phone

      contact = {
        name: user.full_name,
        email_address: user.email,
        phones: phones
      }  

      contacts = {  
        contacts: [contact]
      } 
      response = @@xero_client.accounting_api.create_contacts('318e1b05-b47b-4d49-90c5-4950a0bc31ba', contacts)
      user.update(xero_id: response.contacts.first.contact_id)
    end

    private

    def update_token
      @@xero_client.get_client_credentials_token
    end

  end
end

# AccountBlock::XeroApiService.new.create_contact(user)
  