# This migration comes from bx_block_multilevelapproval (originally 20230518111905)
class RenameTableBxBlockGamificationTemplates < ActiveRecord::Migration[6.0]
  def change
    rename_table :templates, :bx_block_multilevelapproval_templates
  end
end
