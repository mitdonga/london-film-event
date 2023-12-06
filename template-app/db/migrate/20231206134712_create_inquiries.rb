class CreateInquiries < ActiveRecord::Migration[6.0]
  def change
    create_table :inquiries do |t|
      t.bigint :user_id
      t.bigint :service_id
      t.bigint :sub_category_id
      t.text :note
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
