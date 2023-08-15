module BxBlockCustomUserSubs
  class SubscriptionSerializer < BuilderBase::BaseSerializer
    attributes *[
        :name,
        :price,
        :description,
        :valid_up_to
    ]

    attribute :expired do |object|
      object.valid_up_to < Date.today
    end

    attribute :image_link do |object|
      object.image.attached? ? Rails.application.routes.url_helpers.rails_blob_path(
        object.image,only_path: true
      ) : nil
    end

    attribute :subscribed do |object, params|
      BxBlockCustomUserSubs::Subscription.joins(:user_subscriptions).where(
        'user_subscriptions.account_id = ?', params[:user].id
      ).any?
    end

  end
end
