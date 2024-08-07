ActiveAdmin.register BxBlockEmailNotifications::EmailTemplate, as: 'Email Template' do
    menu parent: "Content Management"
    member_action :upload, method: :post do
        success = resource.images.attach(params[:file_upload])
        result = success ? { link: url_for(resource.images.last) } : {}
        render json: result
    end

    permit_params :name, :body, :dynamic_words
    # actions :all, except: [:new]
  
    index do
      selectable_column
      id_column
      column :name
      column :dynamic_words
      actions
    end
  
    show do
      attributes_table do
        row :name
        row :dynamic_words
        row :body do |et|
          raw et.body
        end
      end
    end
  
    form do |f|
      text_node javascript_include_tag  'activeadmin/froala_editor/froala_editor.pkgd.min'
      text_node javascript_include_tag 'activeadmin/froala_editor_input'
       
      f.inputs do
        f.input :name
        f.input :dynamic_words
        f.input :body, as: :froala_editor, input_html: { 
            class: 'rich-text-input',
            data: { 
                options: { 
                    heightMin: 500,
                    imageUploadParam: 'file_upload', 
                    imageUploadURL: resource.id.present? ? upload_admin_email_template_path(resource.id) : nil, 
                    toolbarButtons: {
                    'moreText': {
                        'buttons': ['bold', 'italic', 'underline', 'strikeThrough', 'subscript', 'superscript', 'fontFamily', 'fontSize', 'textColor', 'backgroundColor', 'inlineClass', 'inlineStyle', 'clearFormatting']
                    },
                    'moreParagraph': {
                        'buttons': ['alignLeft', 'alignCenter', 'formatOLSimple', 'alignRight', 'alignJustify', 'formatOL', 'formatUL', 'paragraphFormat', 'paragraphStyle', 'lineHeight', 'outdent', 'indent', 'quote']
                    },
                    'moreRich': {
                        'buttons': ['insertLink', 'insertImage', 'insertVideo', 'insertTable', 'emoticons', 'fontAwesome', 'specialCharacters', 'embedly', 'insertFile', 'insertHR']
                    },
                    'moreMisc': {
                        'buttons': ['undo', 'redo', 'fullscreen', 'print', 'getPDF', 'spellChecker', 'selectAll', 'html', 'help'],
                        'align': 'right',
                        'buttonsVisible': 2
                    }},
                    paragraphFormatSelection: true
                } 
            } 
        }

        # f.input :body, as: :quill_editor, input_html: { 
        #   data: { 
        #     options: { 
        #       modules: {
        #         toolbar: [['bold', 'italic', 'underline'], ['link', 'image']] 
        #       }, 
        #       placeholder: 'Type something...', 
        #       theme: 'snow' 
        #     },
        #     # plugins: { image_uploader: { server_url: resource.id.present? ? upload_admin_email_template_path(resource.id) : "", field_name: 'file_upload' } } 
        #   }
        # }
      end
      f.actions
    end

end
  
