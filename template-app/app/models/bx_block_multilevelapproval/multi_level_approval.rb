module BxBlockMultilevelapproval
  class MultiLevelApproval < BxBlockMultilevelapproval::ApplicationRecord
    self.table_name = :bx_block_multilevelapproval_templates
    
    enum status: ['pending', 'partially_approved', 'approved', 'rejected']
    after_update :update_status, :if => Proc.new { |template| template.status_before_last_save == "rejected" }
    validates :name, presence: true
    validate :validate_status

    def validate_status
        if self.status_was == 'approved' && (self.partially_approved? || self.rejected?)
            errors.add('status', "you can't change status to 'approved' to '#{self.status}'")
        end
    end

    def update_status
        self.update_column(:status, "pending")
    end
  end
end
