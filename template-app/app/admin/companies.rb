ActiveAdmin.register BxBlockInvoice::Company, as: "Company" do
  permit_params :name, :address, :city, :zip_code, :phone_number, :logo, :meeting_link, :email, :company_sub_categories
  # permit_params :all
  NO_IMAGE = "No Logo"
  index do
    selectable_column
    id_column
    column :name
    column :address
    column :city
    column :zip_code
    column :phone_number
    column :email
    column :logo do |c|
      c.logo.present? ?
      image_tag(Rails.application.routes.url_helpers.rails_blob_url(c.logo, only_path: true), width: 100, controls: true) : NO_IMAGE
    end
    actions
  end

  show do
    attributes_table do
      row :name
      row :address
      row :city
      row :zip_code
      row :phone_number
      row :email
      row :meeting_link
      row :logo do |c|
        c.logo.present? ?
        image_tag(Rails.application.routes.url_helpers.rails_blob_url(c.logo, only_path: true), width: 100, controls: true) : NO_IMAGE
      end
    end

    panel "Service Details" do
      table_for company.company_categories.includes(:category) do
        column :service do |company_category|
          company_category.category.name
        end
        column :has_access
      end
    end

    panel "Service Type Pricing" do
      table_for company.company_sub_categories.includes(sub_category: :parent) do
        column :service do |company_sub_category|
          company_sub_category.sub_category.parent.name
        end
        column :service_type do |company_sub_category|
          company_sub_category.sub_category.name
        end
        column :price
      end
    end

    company.services_sub_categories_data.each do |data|
      panel "#{data[:service_name]} Addons" do
        table_for data[:input_fields] do
          column(:input_field_name) { |field| field.input_field.name }
          column(:type) { |field| field.input_field.field_type }
          column(:options) { |field| field.input_field.options }  
          column(:values) { |field| field.input_field.values }  
          column(:multiplier) { |field| field.input_field.multiplier }  
          column(:default_value) { |field| field.input_field.default_value }  
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.inputs :name
      f.inputs :address
      f.inputs :city
      f.inputs :zip_code
      f.inputs :phone_number
      f.inputs :email
      f.inputs :meeting_link
      f.input :logo, as: :file, hint: f.object.logo.present? ? image_tag(Rails.application.routes.url_helpers.rails_blob_url(f.object.logo, only_path: true), width: 200, controls: true) : NO_IMAGE
      if f.object.persisted?
        f.inputs "Manage Sub Category Prices" do
          tabs do
            f.object.services_sub_categories_data.each do |sr|
              tab "#{sr[:service_name]}" do
                f.input "company_categories[#{sr[:company_category_id]}][id]", input_html: { value: sr[:company_category_id] }, as: :hidden
                f.input "company_categories[#{sr[:company_category_id]}][has_access]", collection: [['Yes', true], ['No', false]], selected: sr[:has_access], label: "Available"
                sr[:company_sub_categories].each do |csc|
                  f.input "company_sub_categories[#{csc[:company_sub_category_id]}][id]", input_html: { value: csc[:company_sub_category_id] }, as: :hidden
                  f.input "company_sub_categories[#{csc[:company_sub_category_id]}][price]", as: :number, label: "#{csc[:sub_category_name]} Price", input_html: { value: csc[:price], step: '1', min: '1', required: true  }
                end
                sr[:input_fields].each do |field|
                  div class: "addons-container" do
                    f.input "company_input_fields[#{field.id}][id]", input_html: { value: field.id }, as: :hidden
                    f.input "company_input_fields[#{field.id}][input_field_name]", input_html: { value: field.input_field.name, disabled: true }, label: "Addon Name"
                    f.input "company_input_fields[#{field.id}][input_field_options]", input_html: { value: field.input_field.options, disabled: true }, label: "Options"
                    f.input "company_input_fields[#{field.id}][values]", input_html: { value: field.values }, label: "Values", as: field.input_field.values.present? ? :string : :hidden 
                    f.input "company_input_fields[#{field.id}][multiplier]", input_html: { value: field.multiplier }, label: "Multiplier", as: field.input_field.multiplier.present? ? :string : :hidden
                    f.input "company_input_fields[#{field.id}][default_value]", input_html: { value: field.default_value }, label: "Default value", as: field.input_field.default_value.present? ? :string : :hidden
                  end
                end
              end
            end
          end
        end
      end        
    end

    f.actions
  end

  controller do
    def update
      company = find_resource
      company_sub_categories_data = params.as_json["bx_block_invoice_company"]["company_sub_categories"].values rescue []
      company_sub_categories_data.each do |e|
        next unless e["id"].present? && e["price"].present?
        csc = company.company_sub_categories.find_by_id(e["id"])
        csc.update!(price: e["price"].to_i)
      end
      companies_categories_data = params.as_json["bx_block_invoice_company"]["company_categories"].values rescue []
      companies_categories_data.each do |e|
        next unless e["id"].present?
        cc = company.company_categories.find_by_id(e["id"])
        if cc.present?
          has_access = e["has_access"] == "true" ? true : false
          cc.update!(has_access: has_access)
        end
      end
      company_inputs_data = params.as_json["bx_block_invoice_company"]["company_input_fields"].values rescue []
      company_inputs_data.each do |e|
        cif = company.company_input_fields.find_by_id(e["id"])
        cif.update(e.except("id"))
      end
      super
    end
  end
end
