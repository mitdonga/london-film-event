ActiveAdmin.register BxBlockHelpCentre::QuestionAnswer, as: 'Faq' do
    menu label: "Manage Faqs", parent: "Content Management"
    permit_params :id, :question, :answer, :question_sub_type_id

    index do
        selectable_column
        id_column
        column 'Question', :question
        column 'Answer', :answer
        actions
    end

    show do
        attributes_table do
            row :question
            row :answer
        end
    end

    form do |f|
        f.inputs do
            f.input :question
            f.input :answer
        end
        f.actions
    end
end