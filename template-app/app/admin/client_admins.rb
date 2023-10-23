ActiveAdmin.register AccountBlock::ClientAdmin, as: "Client Admin" do
  menu priority: 3

  filter :first_name
  filter :last_name
  filter :country_code
  filter :phone_number
  filter :email
  filter :activated
  filter :account_type
  filter :company

  permit_params :first_name, :last_name, :full_phone_number, :country_code, :phone_number, :email, :activated, :device_id, :unique_auth_id, :password, :type, :user_name, :platform, :account_type, :app_language_id, :last_visit_at, :is_blacklisted, :suspend_until, :status, :role_id, :stripe_id, :stripe_subscription_id, :stripe_subscription_date, :gender, :date_of_birth, :age, :company_id

  index do 
    selectable_column
    column :id
    column "Name" do |object|
      object.full_name
    end
    column :company
    column :email
    column :full_phone_number
    column :account_type
    column :activated
    actions
  end

  show do
    attributes_table do
      row :first_name
      row :last_name
      row :email
      row :company
      row :account_type
      row :full_phone_number
      row :activated
    end
  end

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :email, input_html: { placeholder: "Enter a valid email" }
      f.input :company, as: :select, prompt: "Select Company"
      f.input :country_code, as: :select, collection: Country.all.sort_by(&:name).map { |c| [ "#{c.country_code} (#{c.name})", c.country_code.to_i] }, prompt: 'Select a country'
      f.input :phone_number, input_html: { placeholder: "Enter a valid phone number" }
      f.input :account_type, prompt: "Select Account Type"
      # f.input :password
    end
    f.actions
  end
end
