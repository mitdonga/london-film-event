ActiveAdmin.register AccountBlock::Account, as: "Users Account Activities" do

    index do 
      selectable_column
      column :id
      column "Name" do |object|
        "#{object.first_name} #{object.last_name}"
      end
      column :email
      column :created_at
      column :last_visit_at
      actions
    end
  
    show do
      attributes_table do
        row :email  
        row :created_at
        row :last_visit_at
      end
  
      panel "User Services" do
        table_for resource.inquiries do
        
          column :service_name do |inquiry|
            inquiry.service.id
          end
          column :service_name do |inquiry|
            inquiry.service.name
          end
          column :service_image do |inquiry|
            if inquiry.service.image.attached?
              image_tag(url_for(inquiry.service.image), width: 100, controls: true)
            else
              'NO_SERVICE_IMAGE'
            end
          end
        end
      end
    end
  
    filter :id
    filter :first_name
    filter :last_name
    filter :email
    filter :last_visit_at
  end
  