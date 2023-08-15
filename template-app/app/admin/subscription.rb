module Subscription
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

unless Subscription::Load.is_loaded_from_gem
  ActiveAdmin.register BxBlockCustomUserSubs::Subscription do
    menu label: "Subscription"
    permit_params :name, :description, :valid_up_to, :price,:image

    form do |f|
      f.inputs do
        f.input :name
        f.input :description
        f.input :price
        f.input :valid_up_to
        f.input :image, as: :file
      end
      f.actions

    end

    index  title: 'Subscriptions' do
      id_column
      column :name
      column :description
      column :price
      column :valid_up_to
      column :image do |s|
        s.image.attached? ? (image_tag url_for(s.image)) : ''
      end
      actions
    end
    show do
      attributes_table do
        row :name
        row :description
        row :price
        row :valid_up_to
        row :image do |s|
          s.image.attached? ? (image_tag url_for(s.image)) : ''
        end
      end
    end
  end
end
