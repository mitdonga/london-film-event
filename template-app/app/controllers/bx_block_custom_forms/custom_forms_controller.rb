module BxBlockCustomForms
  class CustomFormsController < ApplicationController
    before_action :set_form, only: %i(show update destroy)

  	def index
      forms = CustomForm.where(account_id: current_user.id)
      render json: CustomFormSerializer.new(forms, serialization_options)
    end

    def create
      if current_user.custom_form.present?
        render json: {errors: "Custom form already created"}, status: :unprocessable_entity
      else
        form = CustomForm.new(form_params.merge(account_id: current_user.id))

        if form.save
         render json: CustomFormSerializer.new(form, serialization_options), status: :created
        else
         render json: {errors: "Custom form can't be blank"}, status: :unprocessable_entity
        end
      end
    end

    def show
      render json: CustomFormSerializer.new(@form, serialization_options)
    end

    def update
      if @form.update(form_params)
        render json: CustomFormSerializer.new(@form, serialization_options)
      else
        render json: {errors: "Custom form can't be updeted"}, status: :unprocessable_entity
      end
    end

    def destroy
      render json: {message: "deleted."} if @form.destroy
    end

    private

    def serialization_options
      { params: { host: request.base_url } }
    end

    def form_params
      params.require(:form).permit(:first_name, :last_name, :phone_number, :organization, :team_name, :i_am, :gender, :email, :address, :country, :state, :city, :stars_rating, :file )
    end

    def set_form
      @form = CustomForm.find(params[:id])
    end
  end
end
