require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  get "/healthcheck", to: proc { [200, {}, ["Ok"]] }
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad
  namespace :bx_block_login do
    post "login", to: "logins#create"
    delete "logout", to: "logins#destroy"
  end
  root to: redirect("/admin")
  namespace :account_block do
    resources :accounts do
      collection do
        put :update_for_notification
        put :update
        put :change_password
        get :specific_account
        post :add_client_user
        put :update_client_user
        get :client_users
        get :company_users
        get :all_company_users
        put :reset_password_email
        put :reset_password
        delete :remove_user
        post :send_account_activation_email
        put :change_email_address
      end
    end
  end

  namespace :bx_block_terms_and_conditions do
    resources :terms_and_conditions do
      collection do
        put :accept_and_reject
      end
    end
  end

  namespace :bx_block_categories do
    resources :categories, only: [:index] do
      collection do
        get :get_service
        get :form_fields
        get :previous_packages
      end
    end
  end

  namespace :bx_block_contact_us do
    resources :contacts
  end

  namespace :bx_block_notifications do
    resources :notifications do
      collection do
        get 'notification_list'
        get 'unreaded_notifications'
      end
    end
  end

  namespace :bx_block_help_centre do
    resources :question_answer, only: [:index]  do
      collection do
        get 'search_question'
      end
    end
  end

  namespace :bx_block_invoice do
    resources :invoices
  end
  
  namespace :bx_block_profile do
    resources :profiles  do
      collection do
        put 'update_profile'
        put 'popup_confirmation'
      end
    end
  end

  get "/manage_users_inquiries",        to: "bx_block_invoice/invoice#manage_users_inquiries"
  get "/inquiry/:id", to: "bx_block_invoice/invoice#inquiry"
  get "/inquiries", to: "bx_block_invoice/invoice#inquiries"
  post "/create_inquiry", to: "bx_block_invoice/invoice#create_inquiry"
  get "/inquiry/:id",                       to: "bx_block_invoice/invoice#inquiry"
  get "/inquiries",                         to: "bx_block_invoice/invoice#inquiries"
  post "/create_inquiry",                   to: "bx_block_invoice/invoice#create_inquiry"
  put "/manage_additional_services",        to: "bx_block_invoice/invoice#manage_additional_services"
  put "/save_inquiry",                      to: "bx_block_invoice/invoice#save_inquiry"
  put "/calculate_cost",                    to: "bx_block_invoice/invoice#calculate_cost"
  put "/upload_attachment",                 to: "bx_block_invoice/invoice#upload_attachment"
  put "/submit_inquiry",                    to: "bx_block_invoice/invoice#submit_inquiry"
  put "/approve_inquiry",                   to: "bx_block_invoice/invoice#approve_inquiry"
  put "/reject_inquiry",                    to: "bx_block_invoice/invoice#reject_inquiry"
  get "/get_invoices",                      to: "bx_block_invoice/invoice#user_invoices"
  get "/download_invoice_pdf",              to: "bx_block_invoice/invoice#invoice_pdf"
  post "/change_inquiry_sub_category",      to: "bx_block_invoice/invoice#change_inquiry_sub_category"
  delete "/delete_inquiry",                 to: "bx_block_invoice/invoice#delete_inquiry"
  delete "/delete_user_inquiries",          to: "bx_block_invoice/invoice#delete_user_inquiries"
  get "/match_company_domain",              to: "account_block/accounts#match_company_domain"
end
