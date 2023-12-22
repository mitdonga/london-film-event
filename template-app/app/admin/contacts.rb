ActiveAdmin.register BxBlockContactUs::Contact, as: 'Contact Requests' do

  permit_params :id, :first_name, :last_name, :country_code, :phone_number, :email, :subject, :details
  actions :all, except: [:new]

  index do
    selectable_column
    id_column
    column 'First Name', :first_name
    column 'Last Name', :last_name
    column 'Full Phone Number' do |contact|
      "#{contact.country_code}#{contact.phone_number}"
    end
    column 'Email', :email
    column 'Subject', :subject
    column 'Description', :details
    column 'User Type' do |contact|
      contact.account&.type
    end
    actions
  end

  show do
    attributes_table do
      row 'User Type' do |contact|
        contact.account&.type
      end
      row :first_name
      row :last_name
      row :email
      row :subject
      row :details
      row :country_code
      row :phone_number
    end
  end

  form do |f|
   f.semantic_errors(*f.object.errors.keys, class: 'error-block')
    f.inputs do
      f.input :user_type, label: 'User Type', input_html: { value: f.object.account&.type, disabled: true }
      f.input :first_name, label: 'First Name'
      f.input :last_name, label: 'Last Name'
      f.input :country_code, as: :select, collection: Country.all.sort_by(&:name).map { |c| [ "#{c.country_code} (#{c.name})", c.country_code.to_i] }, prompt: 'Select a country', input_html: { disabled: true }
      f.input :phone_number, label: 'Phone Number', input_html: { disabled: true }
      f.input :subject, label: 'Subject'
      f.input :details, label: 'Details'
      f.input :email, label: 'Email', input_html: { disabled: true }
    end
    f.actions
  end
end
