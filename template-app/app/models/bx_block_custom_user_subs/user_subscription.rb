module BxBlockCustomUserSubs
  class UserSubscription < ApplicationRecord
    self.table_name = :user_subscriptions
    belongs_to :account, class_name: "AccountBlock::Account"
    belongs_to :subscription , class_name: "BxBlockCustomUserSubs::Subscription"
  end
end
