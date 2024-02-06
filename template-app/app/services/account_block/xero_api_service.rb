module AccountBlock
  class XeroApiService
    CREDENTIALS = Rails.application.config.xero_credentials
    XERO_TENANT_ID = Rails.application.config.xero_tenant_id
    
    def initialize
      @xero_client = ::XeroRuby::ApiClient.new(credentials: CREDENTIALS)
      @xero_client.get_client_credentials_token 
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

      @invoices = user.xero_id.present? && Rails.env != "test" ? @xero_client.accounting_api.get_invoices(XERO_TENANT_ID, opts).invoices : []
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
  end
end

# AccountBlock::XeroApiService.new.create_contact(user)
  