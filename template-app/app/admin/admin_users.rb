module AdminUsers
  class Load
    @@loaded_from_gem = false
    def self.is_loaded_from_gem
      @@loaded_from_gem
    end

    def self.loaded
    end

    # Check if this file is loaded from gem directory or not
    # The gem directory looks like
    # /template-app/.gems/gems/bx_block_custom_user_subs-0.0.7/app/admin/subscription.rb
    # if it has block's name in it then it's a gem
    @@loaded_from_gem = Load.method('loaded').source_location.first.include?('bx_block_')
  end
end

unless AdminUsers::Load.is_loaded_from_gem
  ActiveAdmin.register AdminUser, as: "LF Admin" do
    permit_params :email, :password, :password_confirmation
    menu priority: 1, label: "LF Admins"
    index title: "LF Admins"
    show title: "LF Admin Details"

    index do
      selectable_column
      id_column
      column :email
      column :current_sign_in_at
      column :sign_in_count
      column :created_at
      actions
    end

    filter :email
    filter :current_sign_in_at
    filter :sign_in_count
    filter :created_at

    form do |f|
      f.inputs do
        f.input :email
        f.input :password
        f.input :password_confirmation
      end
      f.actions
    end

    controller do
      def new
        @page_title = "New LF Admin"
        super
      end
      def edit
        @page_title = "Edit LF Admin"
        super
      end
    end
  end
end
