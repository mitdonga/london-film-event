ActiveAdmin.register AccountBlock::ClientUser, as: "Client User" do
    menu priority: 3

    filter :first_name
    filter :last_name
    filter :country_code
    filter :phone_number
    filter :email
    filter :activated
    filter :account_type
    filter :company
    filter :client_admin, as: :select, collection: AccountBlock::ClientAdmin.all.pluck(:first_name, :id)

    permit_params :first_name, :last_name, :full_phone_number, :job_title, :country_code, :phone_number, :email, :client_admin_id, :activated, :device_id, :unique_auth_id, :password, :type, :user_name, :platform, :account_type, :app_language_id, :last_visit_at, :is_blacklisted, :suspend_until, :status, :role_id, :stripe_id, :stripe_subscription_id, :stripe_subscription_date, :gender, :date_of_birth, :age, :company_id, :location, :profile_picture
  
    index do 
      selectable_column
      column :id
      column "Name" do |object|
        "#{object.first_name} #{object.last_name}"
      end
      column :company
      column :email
      column :full_phone_number
      column :account_type
      column :client_admin do |obj|
        obj.client_admin.full_name
      end
      column :profile_picture do |a|
        if a.profile_picture.present?
          a.profile_picture.blob.content_type.include?("image") ?
          image_tag(Rails.application.routes.url_helpers.rails_blob_url(a.profile_picture, only_path: true), width: 100, controls: true) : a.profile_picture.blob.filename
        else
          NO_FILE
        end
      end
      column :activated
      column :location

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
        row :job_title
        row :client_admin do |obj|
            obj.client_admin.full_name
        end
        row :activated
        row :location
        row("Xero Contact ID") {|f| f.xero_id }
        row :profile_picture do |con_file|
          if con_file.profile_picture.present?
            con_file.profile_picture.blob.content_type.include?("image") ? image_tag(Rails.application.routes.url_helpers.rails_blob_url(con_file.profile_picture, only_path: true), width: 100, controls: true) : con_file.profile_picture.blob.filename
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
        f.input :company, as: :select, prompt: "Select Company", input_html: {id: :company_select }
        f.input :country_code, as: :select, collection: AccountBlock::AccountHelper.country_codes, prompt: 'Select a country'
        f.input :phone_number, input_html: { placeholder: "Enter a valid phone number" }
        f.input :account_type, prompt: "Select Account Type"
        f.input :job_title
        f.input :client_admin_id, as: :select, collection: AccountBlock::ClientAdmin.all.map {|a| [a.full_name, a.id]}, input_html: {id: :client_admin_select, required: true }
        f.input :location
      end
      f.actions
    end
end
  