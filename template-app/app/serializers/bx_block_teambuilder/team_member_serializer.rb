module BxBlockTeambuilder
  class TeamMemberSerializer < BuilderBase::BaseSerializer
    attributes :id, :name, :email

    attribute :image do |object|
      object.image.present? ? Rails.application.routes.url_helpers.url_for(object.image) : ""
    end
  end
end
