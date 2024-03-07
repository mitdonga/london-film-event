# This migration comes from bx_block_multilevelapproval (originally 20231009084003)
class AddParentIdToTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :bx_block_multilevelapproval_templates, :parent_id, :integer
    add_column :bx_block_multilevelapproval_templates, :description, :text
  end
end
