class AddIsBespokeToInquiries < ActiveRecord::Migration[6.0]
  def change
    add_column :inquiries, :is_bespoke, :boolean, default: false
  end
end
