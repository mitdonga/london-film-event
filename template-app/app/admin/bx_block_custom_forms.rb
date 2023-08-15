module BxBlockCustomForms

end

ActiveAdmin.register BxBlockCustomForms::CustomForm, as: 'Form' do
  permit_params :id, :first_name, :last_name, :phone_number, :organization, :team_name, :i_am, :gender, :email, :address, :country, :state, :city, :stars_rating, :file
  actions :all, except: [ :new]

  index do
    selectable_column
    id_column
    column 'First Name', :first_name
    column 'Last Name', :last_name
    column 'Phone Number', :phone_number
    column 'Organization', :organization
    column 'Team Name', :team_name
    column 'I Am', :i_am
    column 'Gender', :gender
    column 'Email', :email
    column 'Address', :address
    column 'Country', :country
    column 'State', :state
    column 'City', :city
    actions
  end


  show do |data|
    attributes_table do
      row :id
      row :first_name
      row :last_name
      row :phone_number
      row :organization
      row :team_name
      row :i_am, :gender
      row :email
      row :address
      row :country, as: :string
      row :state
      row :city
      row :stars_rating
      row :file do |custom_form|
       image_tag(custom_form.file, width:80, height:80 ) if custom_form.file.present?
      end
    end
  end

  form do |f|
   f.semantic_errors(*f.object.errors.keys, class: 'error-block')
    f.inputs do
      f.input :first_name, label: 'First Name'
      f.input :last_name, label: 'Last Name'
      f.input :phone_number, label: 'Phone Number'
      f.input :organization, label: 'Organization'
      f.input :team_name, label: 'Team Name'
      f.input :i_am, label: 'I Am', as: :radio
      f.input :gender, label: 'Gender'
      f.input :email, label: 'Email'
      f.input :address, label: 'Address'
      f.input :country, label: 'Country', as: :string
      f.input :state, label: 'State', as: :string
      f.input :city, label: 'City', as: :string
      f.input :stars_rating, label: 'Stars Rating'
      f.input :file, label: 'File', as: :file
    end
    f.actions
  end
end
