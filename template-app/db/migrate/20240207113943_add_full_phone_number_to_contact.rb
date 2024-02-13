class AddFullPhoneNumberToContact < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :full_mobile_number, :string
  end
end
