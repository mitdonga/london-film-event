module BxBlockContactUs
  class ContactSerializer < BuilderBase::BaseSerializer
    attributes *[
        :first_name,
        :last_name,
        :email,
        :country_code,
        :phone_number,
        :subject,
        :details,
        :created_at,
    ]

    # attribute :user do |object|
    #   user_for object
    # end

    # class << self
    #   private

    #   def user_for(object)
    #     "#{object.account.first_name} #{object.account.last_name}"
    #   end
    # end
  end
end
