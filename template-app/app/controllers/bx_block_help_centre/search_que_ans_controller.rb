module BxBlockHelpCentre
  class SearchQueAnsController < ApplicationController
    def index
      @result = QuestionSubType.where(
        'lower(sub_type) LIKE :search OR lower(description) LIKE :search',
        search: "%#{params[:query].downcase}%"
      ) +
      QuestionAnswer.where(
        'lower(question) LIKE :search OR lower(answer) LIKE :search',
        search: "%#{params[:query].downcase}%"
      )

      if @result.present?
        render json: { data: @result }, status: :ok
      else
        render json: {
          errors: [ { message: 'No match found.'}, ]
        }, status: :unprocessable_entity
      end
    end
  end
end
