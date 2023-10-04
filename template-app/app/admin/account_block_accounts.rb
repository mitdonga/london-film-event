ActiveAdmin.register AccountBlock::Account, as: "Client Admins" do
  menu priority: 2
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :first_name, :last_name, :full_phone_number, :country_code, :phone_number, :email, :activated, :device_id, :unique_auth_id, :password_digest, :type, :user_name, :platform, :user_type, :app_language_id, :last_visit_at, :is_blacklisted, :suspend_until, :status, :role_id, :stripe_id, :stripe_subscription_id, :stripe_subscription_date, :gender, :date_of_birth, :age
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
    end
    column "Email", &:email
    column "Mobile Number", &:full_phone_number
  end

  form do |f|
    f.inputs "Client Admin Details" do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :phone_number
      f.input :password_digest, as: :hidden, input_html: { value: 'lfpass123' }
    end
    f.actions
  end
end
