module BxBlockProfile
  class PasswordsController < ApplicationController
    def update
      status, result = ChangePasswordCommand.execute \
        @token.id,
        update_params[:current_password],
        update_params[:new_password]

      if status == :created
        serializer = AccountBlock::AccountSerializer.new(result)
        render :json => serializer.serializable_hash,
          :status => :created
      else
        render :json => {:errors => [{:profile => result.first}]},
          :status => status
      end
    end

    private

    def update_params
      params.require(:data)
        .permit \
        :current_password,
        :new_password
    end
  end
end
