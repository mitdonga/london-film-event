module BxBlockTeambuilder
  class TeamMember < ApplicationRecord
    self.table_name = :bx_block_teambuilder_team_members
    belongs_to :account, class_name: "AccountBlock::Account", foreign_key: "account_id"
    has_one_attached :image
    validates_uniqueness_of :email, presence: true
  end
end
