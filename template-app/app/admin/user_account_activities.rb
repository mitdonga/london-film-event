ActiveAdmin.register AccountBlock::Account, as: "Users Account Activities" do

    permit_params :first_name, :last_name, :full_phone_number, :country_code, :phone_number, :email, :activated, :device_id, :unique_auth_id, :can_create_accounts, :job_title, :password, :type, :user_name, :platform, :account_type, :app_language_id, :last_visit_at, :is_blacklisted, :suspend_until, :status, :role_id, :stripe_id, :stripe_subscription_id, :stripe_subscription_date, :gender, :date_of_birth, :age, :company_id, :location, :session_duration

    index do 
      selectable_column
      column :id
      column "Name" do |object|
        "#{object.first_name} #{object.last_name}"
      end
      column :email
      column :created_at
      column "Last Login At",:last_visit_at
      column "Last Session Duration",:session_duration
      actions
    end
  
    show do
      attributes_table do

        row :email  
        row :created_at
        row "Last Login At", :last_visit_at do |user|
          user.last_visit_at
        end
        row "Last Session Duration", :last_visit_at do |user|
          user.session_duration
        end

      end
    end
  
    filter :id
    filter :first_name
    filter :last_name
    filter :email
    filter :last_visit_at
  end
  