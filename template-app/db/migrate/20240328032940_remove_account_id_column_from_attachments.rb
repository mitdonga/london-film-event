class RemoveAccountIdColumnFromAttachments < ActiveRecord::Migration[6.0]
  def change
    remove_column :attachments, :account_id, :bigint
    add_column :attachments, :attachable_id, :bigint
    add_column :attachments, :attachable_type, :string
    add_column :attachments, :reference_no, :string
  end
end
