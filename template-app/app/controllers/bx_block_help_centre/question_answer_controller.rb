module BxBlockHelpCentre
  class QuestionAnswerController < ApplicationController
    before_action :get_question_answer, only: [:show, :update, :destroy]

    def index
      @question_answers = QuestionAnswer.all.order('created_at DESC')
      if @question_answers.present?
        render json: QuestionAnswerSerializer.new(
          @question_answers, meta: { message: 'List of question answers.' }
        ).serializable_hash, status: :ok
      else
        render json: {
          errors: [ { message: 'No question found.' },]
        }, status: :unprocessable_entity
      end
    end

    def show
      render json: QuestionAnswerSerializer.new(
        @question_answer,
        meta: { success: true, message: "Question Answer." }
      ).serializable_hash, status: :ok
    end

    def create
      @question_answer = QuestionAnswer.new(jsonapi_deserialize(params))
      if @question_answer.save
        render json: QuestionAnswerSerializer.new(
          @question_answer,
          meta: { message: "Question Answer created." }
        ).serializable_hash, status: :created
      else
        render json: { errors: format_activerecord_errors(@question_answer.errors) },
               status: :unprocessable_entity
      end
    end

    def update
      if @question_answer.update(jsonapi_deserialize(params))
        render json: QuestionAnswerSerializer.new(
          @question_answer,
          meta: { message: "Question Answer updated." }
        ).serializable_hash, status: :ok
      else
        render json: { errors: format_activerecord_errors(@question_answer.errors) },
               status: :unprocessable_entity
      end
    end

    def destroy
      if @question_answer.destroy
        render json: { message: "Question answer deleted." }, status: :ok
      else
        render json: {
          errors: [ { message: 'Question answer did not delete.' } ]
        }, status: :unprocessable_entity
      end
    end
    def get_question_answer
      @question_answer = QuestionAnswer.find_by(id: params[:id])
      return render json: {
        errors: [ { message: 'Question not found.' }, ]
      }, status: :unprocessable_entity unless @question_answer.present?
    end
  end
end
