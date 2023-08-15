module BxBlockCustomUserSubs
  class Subscription < ApplicationRecord
    has_many :user_subscriptions,
             class_name: 'BxBlockCustomUserSubs::UserSubscription'
    has_many :accounts, through: :user_subscriptions, class_name: 'AccountBlock::Account'
    validates :name, presence: true
    validates :description, presence: true
    validates :price, presence: true
    validates :valid_up_to, presence: true

    has_one_attached :image
  end
end
