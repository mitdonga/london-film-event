# This migration comes from bx_block_downloadoptions (originally 20230307093852)
class CreateBxBlockDownloadoptions < ActiveRecord::Migration[6.0]
  def change
    create_table :bx_block_downloadoptions_download_options do |t|
    	t.string :title
    end
  end
end
