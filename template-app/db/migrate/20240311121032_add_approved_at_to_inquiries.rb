class AddApprovedAtToInquiries < ActiveRecord::Migration[6.0]
  def change
    add_column :inquiries, :draft_at, :datetime
    add_column :inquiries, :submitted_at, :datetime
    add_column :inquiries, :partial_approved_at, :datetime
    add_column :inquiries, :approved_at, :datetime
    add_column :inquiries, :rejected_at, :datetime
    add_column :inquiries, :rejected_by_lf_id, :integer
    add_column :inquiries, :rejected_by_ca_id, :integer
    add_column :inquiries, :hold_by_id, :integer
    add_column :inquiries, :hold_at, :integer
  end
end
