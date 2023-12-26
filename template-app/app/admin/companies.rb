ActiveAdmin.register BxBlockInvoice::Company, as: "Company" do
  permit_params :name, :address, :city, :zip_code, :phone_number, :meeting_link, :email, :company_sub_categories
  # permit_params :all

  index do
    selectable_column
    id_column
    column :name
    column :address
    column :city
    column :zip_code
    column :phone_number
    column :email
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
      # if f.object.persisted?
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
      # end        
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
