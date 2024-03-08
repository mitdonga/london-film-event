module BxBlockMultilevelapproval
  class MultiLevelApprovalSerializer
    include FastJsonapi::ObjectSerializer
    attributes *[:id, :name, :description, :status, :comment]
  end
end
