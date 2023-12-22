class AddFieldToContact < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :country_code, :integer
  end
end
