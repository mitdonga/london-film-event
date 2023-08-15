# frozen_string_literal: true

module BxBlockPrivacySetting
  class PrivacySettingsController < ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation

    before_action :validate_json_web_token, except: [:index]
    before_action :current_user, only: %i[create update_settings user_privacy_settings]

    def index
      privacy_settings = BxBlockPrivacySetting::PrivacySetting.all.where(is_active: true).order(id: :DESC)
      if privacy_settings.present?
        render json: {privacy_settings: BxBlockPrivacySetting::PrivacySettingSerializer.new(privacy_settings), message: "all privacy settings fetched successfully"},
          status: 200
      else
        render json: {message: "No privacy settings exist"}, status: 404
      end
    end

    def user_privacy_settings
      privacy_setting = BxBlockPrivacySetting::PrivacySetting.where(account_id: @current_user, is_active: true)
      if privacy_setting.present?
        render json: {privacy_setting: privacy_setting.as_json, message: "all privacy settings fetched successfully"},
          status: 200
      else
        render json: {message: "No privacy settings exist"}, status: 404
      end
    end

    def create
      privacy_settings = []
      consent_for = %w[photos videos posts]
      get_data = params[:data][:data]
      get_data.each do |i|
        unless consent_for.include?(i["consent_for"])
          return render json: {error: "consent for must be (photos/videos/posts)"},
            status: 422
        end
      end
      if @current_user.present?
        privacies = BxBlockPrivacySetting::PrivacySetting.where(account_id: @current_user.id,
          consent_for: consent_for)
      end
      if privacies.present? && (privacies.count >= consent_for.count * 3)
        return render json: {privacy_setting: privacies.as_json, message: "privacy setting already present"},
          status: 200
      end

      get_data.each do |info|
        param = create_params(info)
        privacy_setting = BxBlockPrivacySetting::PrivacySetting.find_or_create_by(param)
        if privacy_setting.valid?
          privacy_settings << privacy_setting.as_json
        else
          return render json: {error: "consent_for: #{privacy_setting[:consent_for]}, and consent_to: #{privacy_setting[:consent_to]},has already been taken"},
            status: 422
        end
      end
      render json: {privacy_setting: privacy_settings, message: "privacy setting created successfully"}, status: 200
    end

    def update_settings
      privacy_setting = BxBlockPrivacySetting::PrivacySetting.where(account_id: @current_user.id)
      if privacy_setting.present?
        get_data = params[:data][:data]
        privacy_setting.each do |privacy|
          get_data.each do |record|
            if record[:id].to_i == privacy[:id]
              param = update_params(record)
              next if privacy.update(param)
              return render json: {error: privacy.errors.full_messages}, status: 422
            end
          end
        end
        render json: {privacy_setting: privacy_setting, message: "privacy setting updated successfully"},
          status: 200
      else
        render json: {error: "can't update, privacy setting not present"}, status: 404
      end
    end

    private

    def required_params
      params.require(:data).permit(:id, :account_id, :consent_for, :access_level, :status, :is_active, :created_by,
        :updated_by, data: [])
    end

    def current_user
      @current_user ||= AccountBlock::Account.find(@token.id) if @token.present?
    end

    def update_params(info)
      add_params = required_params
      add_params[:consent_for] = info["consent_for"]
      add_params[:consent_to] = info["consent_to"]
      add_params[:access_level] = info["access_level"]
      add_params[:status] = info["status"]
      add_params
    end

    def create_params(info)
      add_params = required_params
      add_params[:account_id] = @current_user.id
      add_params[:consent_for] = info["consent_for"]
      add_params[:consent_to] = info["consent_to"]
      add_params[:access_level] = info["access_level"]
      add_params[:status] = info["status"]
      add_params
    end
  end
end
