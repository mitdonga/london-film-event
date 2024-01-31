module AccountBlock
  class XeroApiService

    CREDENTIALS = Rails.application.config.xero_credentials
    @@xero_client = XeroRuby::ApiClient.new(credentials: CREDENTIALS)

    def initialize
      @@xero_client.get_client_credentials_token 
    end

    def get_invoices(user, inv_status=nil,  page=1)
      return [] unless user.xero_id.present?
      status = inv_status.nil? ? ["!=", "DRAFT"] : ["=", inv_status].flatten
      opts = {
        page: page,
        where: {
          # type: ['=', XeroRuby::Accounting::Invoice::ACCREC],
          # fully_paid_on_date: (DateTime.now - 6.month)..DateTime.now,
          # amount_due: ['>=', 0],
          # reference: ['=', "Website Design"],
          # invoice_number: ['=', "INV-0001"],
          contact_id: ['=', user.xero_id],
          # contact_number: ['=', "the-contact-number"],
          # date: (DateTime.now - 2.year)..DateTime.now
          # date: ['>=', DateTime.now - 2.year],
          status: status
        }
      }

      @invoices = user.xero_id.present? && Rails.env != "test" ? @@xero_client.accounting_api.get_invoices('318e1b05-b47b-4d49-90c5-4950a0bc31ba', opts).invoices : []
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
        # name: "#{user.full_name} - #{user.id}",
        email_address: user.email,
        phones: phones
      }  

      contacts = {  
        contacts: [contact]
      }
      return if Rails.env == "test"
      response = @@xero_client.accounting_api.create_contacts('318e1b05-b47b-4d49-90c5-4950a0bc31ba', contacts)
      user.update(xero_id: response.contacts.first.contact_id)
    end
  end
end

# AccountBlock::XeroApiService.new.create_contact(user)
  