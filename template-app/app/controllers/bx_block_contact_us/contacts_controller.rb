module BxBlockContactUs
  class ContactsController < ApplicationController

    # before_action :find_contact, only: [:show, :update, :destroy]

    # def index
    #   @contacts = Contact.filter(params[:q]).order(:name)

    #   render json: ContactSerializer
    #                    .new(@contacts)
    #                    .serializable_hash
    # end

    # def show
    #   render json: ContactSerializer
    #                    .new(@contact)
    #                    .serializable_hash, status: :ok
    # end

    def create
      unless verify_email
        return render json: { errors: [{ message: flash[:alert] }] }, status: :unprocessable_entity
      end
    
      @contact = Contact.new(contact_params.merge(account_id: @token.id))
      @user = AccountBlock::Account.find(@token.id)
      if @contact.save
        BxBlockContactUs::ContactMailer.send_mail(@contact).deliver_now
        BxBlockContactUs::ContactMailer.email_for_user(@contact, @user).deliver_now

        create_notification_for_contact_creation(@contact)
    
        render json: ContactSerializer
                         .new(@contact)
                         .serializable_hash, status: :created
      else
        render json: { errors: [{ contact: @contact.errors.full_messages }] }, status: :unprocessable_entity
      end
    end

    # def update
    #   if @contact.update(contact_params)
    #     render json: ContactSerializer
    #                      .new(@contact)
    #                      .serializable_hash, status: 200
    #   else
    #     render json: {errors: [
    #         {contact: @contact.errors.full_messages},
    #     ]}, status: :unprocessable_entity
    #   end
    # end

    # def destroy
    #   @contact.destroy

    #   render json: {
    #       message: "Contact destroyed successfully"
    #   }, status: 200
    # end

    private

    # def find_contact
    #   begin
    #     @contact = Contact.find(params[:id])
    #   rescue ActiveRecord::RecordNotFound => e
    #     return render json: {errors: [
    #         {contact: 'Contact Not Found'},
    #     ]}, status: 404
    #   end
    # end
    
    def create_notification_for_contact_creation(contact)
      BxBlockNotifications::Notification.create(
        account: AccountBlock::Account.find(contact.account_id),
        headings: 'New Contact Created',
        contents: "A new contact with id #{contact.id} has been created."
      )
    end

    def verify_email
      @email = params[:email]
      client_admin_exists = AccountBlock::ClientAdmin.exists?(email: @email)
      client_user_exists = AccountBlock::ClientUser.exists?(email: @email)
  
      if client_admin_exists || client_user_exists
        return true
      else
        flash[:alert] = "Unauthorized user mail,Please provide correct email."
        return false
      end
    end
  
    def contact_params
      permitted_params = [:first_name, :country_code, :last_name, :email, :full_mobile_number, :phone_number, :subject, :details]
      permitted_params << :file if params[:file].present?
      params.permit(permitted_params)    
    end
  end
end