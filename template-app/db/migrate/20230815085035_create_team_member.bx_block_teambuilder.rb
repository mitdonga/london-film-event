# This migration comes from bx_block_teambuilder (originally 20230522070738)
class CreateTeamMember < ActiveRecord::Migration[6.0]
  def change
    create_table :bx_block_teambuilder_team_members do |t|
      t.string :name
      t.string :email
      t.references :account
    end
  end
end
