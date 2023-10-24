ActiveAdmin.register BxBlockTermsAndConditions::TermsAndCondition, as: "Terms And Conditions" do
  
    permit_params :description, :for_whom
    
      form do |f|
        f.inputs do 
          f.input :for_whom
          f.input :description, as: :quill_editor, input_html: { data: { options: { modules: { toolbar: [ ['bold', 'italic', 'underline', 'strike'],['blockquote', 'code-block'],  [{ 'header': 1 }, { 'header': 2 }], [{ 'list': 'ordered'}, { 'list': 'bullet' }], [{ 'script': 'sub'}, { 'script': 'super' }], [{ 'indent': '-1'}, { 'indent': '+1' }], [{ 'direction': 'rtl' }], [{ 'size': ['small', false, 'large', 'huge'] }], [{ 'header': [1, 2, 3, 4, 5, 6, false] }], [{ 'color': [] }, { 'background': [] }], [{ 'font': [] }], [{ 'align': [] }], ['clean'] ] }, theme: 'snow' } } }
        end
        f.actions
      end
    
    index title: "Terms & Conditions" do
      selectable_column
      id_column
      column :for_whom
      column :terms_and_condition do |term|
        div :class => "quill-editor" do 
          truncate(term.description.html_safe, omision: "...", length: 50)
        end
      end
      actions
    end
   
    show do |d|
        attributes_table do
        #   row :for_whom
          div :class => "quill-editor" do
            d.description.html_safe
          end
      end
    end
  end
  