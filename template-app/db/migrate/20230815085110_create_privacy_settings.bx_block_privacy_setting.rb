# This migration comes from bx_block_privacy_setting (originally 20230116102109)
class CreatePrivacySettings < ActiveRecord::Migration[6.0]
  def change
    create_table :bx_block_privacy_settings_privacy_settings do |t|
      t.references :account, null: false
      t.string	:consent_to
      t.string	:consent_for
      t.string	:access_level
      t.string	:status
      t.string	:created_by
      t.string	:updated_by
      t.boolean :is_active
      t.timestamps
    end
  end
end
