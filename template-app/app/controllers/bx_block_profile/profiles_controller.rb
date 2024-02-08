module BxBlockProfile
  class ProfilesController < ApplicationController
    before_action :current_user, on: :update

    # def create
    #   @profile = BxBlockProfile::Profile.new(profile_params.merge({account_id: current_user.id}))
    #   if @profile.save
    #     render json: BxBlockProfile::ProfileSerializer.new(@profile
    #     ).serializable_hash, status: :created
    #   else
    #     render json: {
    #       errors: format_activerecord_errors(@profile.errors)
    #     }, status: :unprocessable_entity
    #   end
    # end

    def show
      profile = AccountBlock::Account.find(params[:id])
      if profile.present?
        render json: ProfileSerializer.new(profile).serializable_hash,status: :ok
      else
        render json: {
          errors: format_activerecord_errors(profile.errors)
        }, status: :unprocessable_entity
      end
    end

    def popup_confirmation
      if @account.update!(account_params)
        render json: AccountBlock::AccountSerializer.new(@account).serializable_hash, status: :ok
        BxBlockContactUs::ContactMailer.send_profile_mail(@account).deliver_now
      else
        render json: {errors: @account.errors.full_messages}, status: :unprocessable_entity
      end
    end

    # def custom_user_profile_fields
    #    fields = BxBlockProfile::CustomUserProfileFields.all
    #   if fields.present?
    #      modified_fields = fields&.map do |field| 
    #       { name: field[:name], title: field[:name].titleize, field_type: field[:field_type] , is_enable: field[:is_enable] , is_required: field[:is_required] }
    #      end
    #     render json: { data: modified_fields },status: :ok
    #   else
    #     render json: {
    #       data: []
    #     }, status: :unprocessable_entity
    #   end
    # end

    # def destroy
    #   profile = BxBlockProfile::Profile.find(params[:id])
    #   if profile.present?
    #     profile.destroy
    #     render json:{ meta: { message: "Profile Removed"}}
    #   else
    #     render json:{meta: {message: "Record not found."}}
    #   end
    # end

    # def update_profile
    #   profile = BxBlockProfile::Profile.find_by(id: params[:id])
    #   if profile.update(profile_params)
    #     render json: ProfileSerializer.new(profile, meta: {
    #         message: "Profile Updated Successfully"
    #       }).serializable_hash, status: :ok
    #   else
    #     render json: {
    #       errors: format_activerecord_errors(profile.errors)
    #     }, status: :unprocessable_entity
    #   end
    # end

    # def update_user_profile
    #   profile = BxBlockProfile::Profile.find_by(account_id:current_user&.id)
    #   if profile.present?
    #      profile.reload_custom_fields
    #     if profile.update(profile_params)
    #       render json: ProfileSerializer.new(profile, meta: {
    #           message: "Profile Updated Successfully"
    #         }).serializable_hash, status: :ok
    #     else
    #       render json: {
    #         errors: format_activerecord_errors(profile.errors)
    #       }, status: :unprocessable_entity
    #     end
    #   else
    #     render json: {
    #         errors: ['Profile not found'] 
    #       }, status: :unprocessable_entity
    #   end
    # end

    def update_profile
      @accounts = AccountBlock::Account.all
    
      if @accounts.any? { |account| account.email == params[:account][:email] && account.id != @token.id }
        render json: { errors: ["Email is already associated with a different account."] }, status: :unprocessable_entity
        return
      end
    
      if params[:account][:email].blank?
        render json: { errors: "Email can't be blank." }, status: :unprocessable_entity
        return
      end
      
      status, result = UpdateAccountCommand.execute(@token.id, account_params)
      phone = Phonelib.parse("#{result.full_phone_number}")
      result.update(country_code: phone.country_code, phone_number: phone.raw_national)
    
      if verify_domain && status == :ok
        serializer = AccountBlock::AccountSerializer.new(result)
        render json: serializer.serializable_hash, status: :ok
      elsif verify_domain && params[:account][:email] == @account.email
        render json: { errors: result&.map { |message| message.sub(/\AEmail\s*/, '') } }, status: :unprocessable_entity
      else
        render json: { errors: "You've entered an email from an external domain. Please confirm this is correct before saving." }, status: :unprocessable_entity
      end
    end
    

    # def like_count
    #   count = 0
    #   @account = AccountBlock::Account.find_by(id: @token.id)
    #   if @account.present?
    #     like_counts = BxBlockPosts::Post.where(account_id: current_user.id)
    #     like_counts.each do |post|
    #       like = BxBlockLike::Like.where(likeable_id: post&.id).count
    #       count += like
    #     end
    #     render :json => {:like_counts => [count: count]},
    #       :status => status
    #   else
    #     render :json => {:errors => [{:account => 'account_id is not valid'}]},
    #       :status => status   
    #   end  
    # end  

    # def user_profiles
    #   profiles = current_user.profiles
    #   render json: ProfileSerializer.new(profiles, meta: {
    #     message: "Successfully Loaded"
    #   }).serializable_hash, status: :ok
    # end

    # def current_user_profile
    #   profile = current_user.profiles&.last
    #   render json: ProfileSerializer.new(profile).serializable_hash, status: :ok
    # end

    def verify_domain
      new_email = params[:account][:email]
      return false unless new_email.present? && @account.email.present?
  
      current_domain = @account.email.split('@').last
      new_domain = new_email.split('@').last
      current_domain == new_domain
    end


    private

    def current_user
      @account = AccountBlock::Account.find_by(id: @token.id)
    end

    def account_params
      params.require(:account).permit(:first_name, :last_name, :email, :phone_number, :country_code, :location, :profile_picture, :full_phone_number)
    end

    # Added required params need to be updated
    # def profile_params
    #   custom_user_profile_params =  BxBlockProfile::CustomUserProfileFields.all&.map(&:name)
    #   params.require(:profile).permit(:id, :country, :photo, :profile_video, :address, :city, :postal_code, :profile_role, :bio, :user_name, :name, :instagram, :youtube, :facebook, :dob, :email, :first_name, :last_name, *custom_user_profile_params, profile_bio_attributes:[:id, :about_me, custom_attributes:{}], qr_code_attributes: [:id, :qr_code])
    # end

    # Added required params need to be updated
    # def update_params
    #   custom_user_profile_params =  BxBlockProfile::CustomUserProfileFields.all&.map(&:name)
    #   params.require(:data).permit \
    #     :id,
    #     :first_name,
    #     :last_name,
    #     :current_password,
    #     :new_password,
    #     :new_email,
    #     :new_phone_number, :full_name, :date_of_birth, :gender, :email,
    #     :bio,
    #     :user_name,
    #     :instagram,
    #     :youtube,
    #      *custom_user_profile_params,
    #     :profile_video, :name
    # end
  end
end