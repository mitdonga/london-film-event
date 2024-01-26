ActiveAdmin.register BxBlockContactUs::Contact, as: 'Contact Requests' do

  permit_params :id, :first_name, :last_name, :country_code, :phone_number, :email, :subject, :details, :file
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
    column :file do |a|
      if a.file.present?
        a.file.blob.content_type.include?("image") ?
        image_tag(Rails.application.routes.url_helpers.rails_blob_url(a.file, only_path: true), width: 100, controls: true) : a.file.blob.filename
      else
        NO_FILE
      end
    end
    actions
  end

  show do
    attributes_table do
      row 'User Account Type' do |contact|
        contact.account&.type
      end
      row :first_name
      row :last_name
      row :email
      row :subject
      row :details
      row :country_code
      row :phone_number
      row :file do |con_file|
        if con_file.file.present?
          con_file.file.blob.content_type.include?("image") ? image_tag(Rails.application.routes.url_helpers.rails_blob_url(con_file.file, only_path: true), width: 100, controls: true) : con_file.file.blob.filename
        else
          NO_FILE
        end
      end
      
      panel "Attachment" do
        if resource.file.attached?
          link_to 'Download File', rails_blob_path(resource.file, disposition: 'attachment'), class: 'button'
        else
          'No attachment'
        end
      end
    end
  end

  form do |f|
   f.semantic_errors(*f.object.errors.keys, class: 'error-block')
    f.inputs do
      f.input :user_type, label: 'Type Of User', input_html: { value: f.object.account&.type, disabled: true }
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
