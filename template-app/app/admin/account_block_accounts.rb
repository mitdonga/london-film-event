ActiveAdmin.register AccountBlock::Account, as: "Client Admins" do
  menu priority: 2
  config.filters = false
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :first_name, :last_name, :full_phone_number, :country_code, :phone_number, :email, :activated, :device_id, :unique_auth_id, :password_digest, :type, :user_name, :platform, :user_type, :app_language_id, :last_visit_at, :is_blacklisted, :suspend_until, :status, :role_id, :stripe_id, :stripe_subscription_id, :stripe_subscription_date, :gender, :date_of_birth, :age, :company_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:first_name, :last_name, :full_phone_number, :country_code, :phone_number, :email, :activated, :device_id, :unique_auth_id, :password_digest, :type, :user_name, :platform, :user_type, :app_language_id, :last_visit_at, :is_blacklisted, :suspend_until, :status, :role_id, :stripe_id, :stripe_subscription_id, :stripe_subscription_date, :gender, :date_of_birth, :age]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  index do 
    selectable_column
    column "Client Admin ID" do |object|
      object.id
      link_to object.id, admin_client_admin_path(object.id)
    end
    column "Name" do |object|
      "#{object.first_name} #{object.last_name}"
    end
    column "Company" do |object|
      object.company
    end
    column "Email", &:email
    column "Mobile Number", &:full_phone_number
  end

  show title: proc { |client_account| "Client Account #{client_account.id}" } do
    attributes_table do
      row :user_type
      row :first_name
      row :last_name
      row :email
      row :country_code
      row :company
      row :full_phone_number
    end
  end

  form do |f|
    f.inputs "Client Admin Details" do
      f.semantic_errors
      f.input :user_type, as: :select, label: "Account Type", collection: ["Convene", "Corporate"], prompt: "Select Account Type"
      f.input :first_name
      f.input :last_name
      f.input :email, input_html: { placeholder: "Enter a valid email" }
      f.input :company, as: :select, prompt: "Select Company"
      f.input :country_code, as: :select, collection: Country.all.map { |c| [ "#{c.country_code} (#{c.name})", c.country_code.to_i] }, prompt: 'Select a country'
      f.input :full_phone_number, input_html: { placeholder: "Enter a valid phone number" }
      f.input :password_digest, as: :hidden, input_html: { value: 'lfpass123' }
    end
    f.actions
  end
end
