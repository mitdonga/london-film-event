module BxBlockHelpCentre
  class QuestionSubTypeController < ApplicationController
    before_action :get_question_sub_type, only: [:show, :update, :destroy]
    def index
      @question_sub_types = QuestionSubType.all.order('created_at DESC')
      if @question_sub_types.present?
        render json: QuestionSubTypeSerializer.new(
          @question_sub_types, meta: { message: 'List of question sub types.' }
        ).serializable_hash, status: :ok
      else
        render json: {errors: [{ message: 'No question sub type found.' },
        ]}, status: :unprocessable_entity
      end
    end

    def show
      render json: QuestionSubTypeSerializer.new(
        @question_sub_type,
        meta: { success: true, message: "Question sub type." }
      ).serializable_hash, status: :ok
    end

    def create
      @question_sub_type = QuestionSubType.new(jsonapi_deserialize(params))
      if @question_sub_type.save
        render json: QuestionSubTypeSerializer.new(
          @question_sub_type,
          meta: { message: "Question sub type created." }
        ).serializable_hash, status: :created
      else
        render json: { errors: format_activerecord_errors(@question_sub_type.errors) },
               status: :unprocessable_entity
      end
    end

    def update
      if @question_sub_type.update(jsonapi_deserialize(params))
        render json: QuestionSubTypeSerializer.new(
          @question_sub_type,
          meta: { message: "Question sub type updated." }
        ).serializable_hash, status: :ok
      else
        render json: { errors: format_activerecord_errors(@question_sub_type.errors) },
               status: :unprocessable_entity
      end
    end

    def destroy
      if @question_sub_type.destroy
        render json: { message: "Question sub type deleted." }, status: :ok
      else
        render json: { errors: [
          { message: 'Question sub type did not delete.' }
        ] }, status: :unprocessable_entity
      end
    end

    private
    def get_question_sub_type
      @question_sub_type = QuestionSubType.find_by(id: params[:id])
      return render json: {
        errors: [ { message: 'Question sub type not found.' }, ]
      }, status: :unprocessable_entity unless @question_sub_type.present?
    end
  end
end
