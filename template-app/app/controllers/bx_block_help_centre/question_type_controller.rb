module BxBlockHelpCentre
  class QuestionTypeController < ApplicationController
    before_action :get_question_type, only: [:show, :update, :destroy]
    def index
      @question_types = QuestionType.all.order('created_at DESC')

      if @question_types.present?
        render json: QuestionTypeSerializer.new(@question_types).serializable_hash, status: :ok
      else
        render json: {
          errors: [ { message: 'No question type found.' }, ]
        }, status: :unprocessable_entity
      end
    end

    def show
      render json: QuestionTypeSerializer.new(
        @question_type,
        meta: { success: true, message: "Question type." }
      ).serializable_hash, status: :ok
    end

    def create
      @question_type = QuestionType.new(jsonapi_deserialize(params))
      if @question_type.save
        render json: QuestionTypeSerializer.new(
          @question_type,
          meta: { message: "Question Type created." }
        ).serializable_hash, status: :created
      else
        render json: { errors: format_activerecord_errors(@question_type.errors) },
               status: :unprocessable_entity
      end
    end

    def update
      if @question_type.update(jsonapi_deserialize(params))
        render json: QuestionTypeSerializer.new(
          @question_type,
          meta: { message: "Question type updated." }
        ).serializable_hash, status: :ok
      else
        render json: { errors: format_activerecord_errors(@question_type.errors) },
               status: :unprocessable_entity
      end
    end

    def destroy
      if @question_type.destroy
        render json: { message: "Question type deleted."}, status: :ok
      else
        render json: {
          errors: [ { message: 'Question type did not delete.' } ]
        }, status: :unprocessable_entity
      end
    end

    private
    def get_question_type
      @question_type = QuestionType.find_by(id: params[:id])
      return render json: {
        errors: [ { message: 'Question type not found.' }, ]
      }, status: :unprocessable_entity unless @question_type.present?
    end
  end
end
