module BxBlockTeambuilder
  module PatchAccountEmployeesAssociation
    extend ActiveSupport::Concern

    included do
      has_many :employees,
               class_name: 'BxBlockTeambuilder::TeamMember',
               foreign_key: 'account_id',
               dependent: :destroy
    end
  end
end
