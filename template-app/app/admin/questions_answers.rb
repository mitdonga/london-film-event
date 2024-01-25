ActiveAdmin.register BxBlockHelpCentre::QuestionAnswer, as: 'FAQs' do
    permit_params :id, :question, :answer, :question_sub_type_id
    actions :all, except: [:show]

    index do
        selectable_column
        id_column
        column 'Question', :question
        column 'Answer', :answer
        actions
    end

    form do |f|
        f.inputs do
            f.input :question
            f.input :answer
        end
        f.actions
    end
end