# frozen_string_literal: true

module BxBlockPrivacySetting
  class PrivacySetting < ApplicationRecord
    self.table_name = :bx_block_privacy_settings_privacy_settings
    belongs_to :account, class_name: "AccountBlock::Account", optional: true
    validates :consent_for, presence: true, uniqueness: {scope: %i[consent_to account_id]}
    before_create :set_data

    private

    def set_data
      self.is_active = true
    end
  end
end
