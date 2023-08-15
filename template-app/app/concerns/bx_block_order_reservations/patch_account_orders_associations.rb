module BxBlockOrderReservations
  module PatchAccountOrdersAssociations
    extend ActiveSupport::Concern

    included do
      has_many :account_orders, class_name: "BxBlockOrderReservations::AccountOrder", dependent: :destroy
    end
  end
end
