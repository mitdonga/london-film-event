module BxBlockPrivacySetting
  class PrivacySettingSerializer < BuilderBase::BaseSerializer
    # include JSONAPI::Serializer
    attributes(:account_id, :consent_to, :consent_for, :access_level, :status, :is_active, :created_by, :updated_by)
  end
end
