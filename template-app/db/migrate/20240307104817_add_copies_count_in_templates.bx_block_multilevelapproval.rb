# This migration comes from bx_block_multilevelapproval (originally 20230907100451)
class AddCopiesCountInTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :bx_block_multilevelapproval_templates, :is_copy, :boolean, :default => false
    add_column :bx_block_multilevelapproval_templates, :copies_count, :integer,  default: 0
  end
end
