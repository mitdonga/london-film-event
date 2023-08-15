# This migration comes from bx_block_custom_forms (originally 20230529141252)
class CreateCustomForms < ActiveRecord::Migration[6.0]
  def change
    create_table :bx_block_custom_forms_custom_forms do |t|
      t.string :first_name
      t.string :last_name
      t.bigint :phone_number
      t.string :email
      t.string :organization
      t.string :team_name
      t.integer :i_am
      t.integer :gender
      t.string :address
      t.string :city
      t.string :state
      t.string :country
      t.integer :zip_code
      t.integer :account_id
      t.timestamps
    end
  end
end
