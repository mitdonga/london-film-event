Rails.application.routes.draw do
  get "/healthcheck", to: proc { [200, {}, ["Ok"]] }
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad
  namespace :bx_block_login do
    post "login", to: "logins#create"
  end

  namespace :account_block do
    resources :accounts do
      collection do
        put :update
        put :change_password
        get :specific_account
        post :add_client_user
        get :client_users
        put :reset_password_email
        put :reset_password
        delete :remove_user
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
      end
    end
  end

  get "/inquiry/:id", to: "bx_block_invoice/invoice#inquiry"
  get "/inquiries", to: "bx_block_invoice/invoice#inquiries"
  post "/create_inquiry", to: "bx_block_invoice/invoice#create_inquiry"
end
