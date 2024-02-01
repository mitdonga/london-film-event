module BxBlockNotifications
  class Notification < ApplicationRecord
    self.table_name = :notifications
    belongs_to :account, class_name: 'AccountBlock::Account'
    has_many :email_notifications, class_name: 'BxBlockEmailNotifications::EmailNotification'
    validates :headings, :contents, :account_id, presence: true, allow_blank: false
  end
end
