ActiveAdmin.register AccountBlock::ClientAdmin, as: "Client Admin" do
  menu priority: 3, parent: "User Management"

  filter :first_name
  filter :last_name
  filter :country_code
  filter :phone_number
  filter :email
  filter :activated
  filter :account_type
  filter :company

  permit_params :first_name, :last_name, :number, :country_code, :phone_number, :email, :activated, :device_id, :unique_auth_id, :can_create_accounts, :job_title, :password, :type, :user_name, :platform, :account_type, :app_language_id, :last_visit_at, :is_blacklisted, :suspend_until, :status, :role_id, :stripe_id, :stripe_subscription_id, :stripe_subscription_date, :gender, :date_of_birth, :age, :company_id, :location

  index do
    selectable_column
    column :id
    column "Name" do |object|
      object.full_name
    end
    column :company
    column :email
    column :number do |obj|
      "+#{obj.country_code} #{obj.phone_number}"
    end
    column :account_type
    column("Account creation permission") {|f| f.can_create_accounts }
    column :activated
    column :location
    column :profile_picture do |a|
      if a.profile_picture.present?
        a.profile_picture.blob.content_type.include?("image") ?
        image_tag(Rails.application.routes.url_helpers.rails_blob_url(a.profile_picture, only_path: true), width: 100, controls: true) : a.profile_picture.blob.filename
      else
        NO_FILE
      end
    end
    actions
  end

  show do
    attributes_table do
      row :first_name
      row :last_name
      row :email
      row :number do |num|
        "+#{num.country_code} #{num.phone_number}"
      end
      row :company
      row :job_title
      row :account_type
      row("Account creation permission") {|f| f.can_create_accounts }
      row :activated
      row :location
      row("Xero Contact ID") {|f| f.xero_id }
      row :profile_picture do |fi|
        if fi.profile_picture.present?
          fi.profile_picture.blob.content_type.include?("image") ? image_tag(Rails.application.routes.url_helpers.rails_blob_url(fi.profile_picture, only_path: true), width: 100, controls: true) : fi.profile_picture.blob.filename
        else
          NO_FILE
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :email, input_html: { placeholder: "Enter a valid email" }
      f.input :country_code, as: :select, collection: AccountBlock::AccountHelper.country_codes, prompt: 'Select a country'
      f.input :phone_number, input_html: { placeholder: "Enter a valid phone number" }
      f.input :company, as: :select, prompt: "Select Company"
      f.input :job_title
      f.input :can_create_accounts, label: "Account creation permission"
      f.input :account_type, prompt: "Select Account Type"
      f.input :location
    end
    f.actions
  end
end
