# This migration comes from bx_block_multilevelapproval (originally 20230309073323)
class CreateTemplates < ActiveRecord::Migration[6.0]
  def change
    create_table :templates do |t|
      t.string :name
      t.integer :company_id

      t.timestamps
    end
  end
end
