# This migration comes from bx_block_multilevelapproval (originally 20230329101448)
class AddStatusInTemplate < ActiveRecord::Migration[6.0]
  def change
  	add_column :templates, :status, :integer, default: 0
  end
end
