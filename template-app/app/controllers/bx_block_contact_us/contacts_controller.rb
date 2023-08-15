module BxBlockContactUs
  class ContactsController < ApplicationController

    before_action :find_contact, only: [:show, :update, :destroy]

    def index
      @contacts = Contact.filter(params[:q]).order(:name)

      render json: ContactSerializer
                       .new(@contacts)
                       .serializable_hash
    end

    def show
      render json: ContactSerializer
                       .new(@contact)
                       .serializable_hash, status: :ok
    end

    def create
      @contact = Contact.new(contact_params.merge(account_id: @token.id))

      if @contact.save
        render json: ContactSerializer
                         .new(@contact)
                         .serializable_hash, status: :created
      else
        render json: {errors: [
            {contact: @contact.errors.full_messages},
        ]}, status: :unprocessable_entity
      end
    end

    def update
      if @contact.update(contact_params)
        render json: ContactSerializer
                         .new(@contact)
                         .serializable_hash, status: 200
      else
        render json: {errors: [
            {contact: @contact.errors.full_messages},
        ]}, status: :unprocessable_entity
      end
    end

    def destroy
      @contact.destroy

      render json: {
          message: "Contact destroyed successfully"
      }, status: 200
    end

    private

    def find_contact
      begin
        @contact = Contact.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        return render json: {errors: [
            {contact: 'Contact Not Found'},
        ]}, status: 404
      end
    end

    def contact_params
      params.require(:data).permit(:name, :email, :phone_number, :description)
    end
  end
end
