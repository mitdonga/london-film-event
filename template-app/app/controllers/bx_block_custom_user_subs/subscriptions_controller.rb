module BxBlockCustomUserSubs
  class SubscriptionsController < ApplicationController

    def index
      subscriptions = BxBlockCustomUserSubs::Subscription.all
      render json: BxBlockCustomUserSubs::SubscriptionSerializer
                       .new(subscriptions, params: {user: current_user})
                       .serializable_hash
    end
  end
end
