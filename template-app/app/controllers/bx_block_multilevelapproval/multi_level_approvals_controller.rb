module BxBlockMultilevelapproval
  class MultiLevelApprovalsController < BxBlockMultilevelapproval::ApplicationController
  include BuilderJsonWebToken::JsonWebTokenValidation
    before_action :validate_json_web_token, only: %i[create update approve_or_reject_with_comment]
    before_action :get_template, only: [:show, :update, :approve_or_reject_with_comment]

     def index
      @templates = MultiLevelApproval.order(id: :desc).where(status: params[:status])
      total_data = @templates.count
      total_page = (total_data.to_f / params[:per_page].to_i).ceil rescue 0
      @templates = Kaminari.paginate_array(@templates).page(params[:page]).per(params[:per_page]) if params[:page].present? && params[:per_page].present?
      if @templates.present?
        render json: {template: MultiLevelApprovalSerializer.new(@templates),  total_data: total_data,total_page: total_page}
      else
        render json: {message:'No Records Found!'}
      end
    end

    def create
      return render json: {error: "Level-1 and level-2 user cannot create template "} unless current_user.role == 'level-0'
        template = MultiLevelApproval.new(create_template_params)
      if template.save
          render json: MultiLevelApprovalSerializer.new(template)
      else
          render json: {error: template.errors.full_messages}
      end
    end

    def update
      unless @template.approved?
        if current_user.role == 'level-0' && @template.rejected?
          update_template_params['status'] = 'pending'
        end
        if @template.update(update_template_params)
          render json: MultiLevelApprovalSerializer.new(@template)
        else
          render json: {error: @template.errors.full_messages}
        end
      else
       render json: { error: "User with an approved role cannot update the name and description." }
      end
    end

    def approve_or_reject_with_comment
      hash = {"level-1" => ["partially_approved", "rejected"], "level-2" => ["approved", "rejected"]}
      if hash[current_user.role]&.include?(params[:status]) && @template.update(status_params)
        render json: MultiLevelApprovalSerializer.new(@template)
      else
        render json: {error: @template.errors}
      end    
    end

    def show
      render json: MultiLevelApprovalSerializer.new(@template)
    end

    private
    
    def create_template_params
      params.require(:template).permit(:name, :company_id, :description)
    end

    def status_params
      params.permit(:status, :comment)
    end

     def get_template
      @template = MultiLevelApproval.find_by(id: params[:id])
      render json: {errors: [{message: "Record not found"}]}, status: :unprocessable_entity and return unless @template.present?
    end

    def update_template_params
      params.require(:template).permit(:status, :name, :description
      )
    end
  end
end
