# This migration comes from bx_block_multilevelapproval (originally 20230824063253)
class AddFieldsToTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :bx_block_multilevelapproval_templates, :approved_by, :integer
    add_column :bx_block_multilevelapproval_templates, :comment, :string
  end
end
