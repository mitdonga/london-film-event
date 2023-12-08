class AddMeetingLinkToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :bx_block_invoice_companies, :meeting_link, :string
  end
end
