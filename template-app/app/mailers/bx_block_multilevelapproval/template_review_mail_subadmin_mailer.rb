module BxBlockMultilevelapproval
  class TemplateReviewMailSubadminMailer < ApplicationMailer
    def template_review_request
      @account = params[:account]
      @host = Rails.env.development? ? 'http://localhost:3000' : params[:host]
      @template = params[:template]

      @url = "#{@host}/admin/templates?scope=under_review"
      @template_url = "#{@host}/admin/templates/#{@template.id}"
      mail(
          to: @account.email,
          from: 'builder.bx_dev@engineer.ai',
          subject: "Template review request for template Id-#{@template.id}") do |format|
        format.html { render 'template_review_request' }
      end
    end

    private


  end
end
