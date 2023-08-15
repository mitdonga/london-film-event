ActiveAdmin.register BxBlockOrderReservations::ReservationService, as: "ReservationServices" do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :price, :city, :full_address, :reservation_date, :state, :zip_code, :image, :service_name, :booking_status, :slot_start_time, :slot_end_time
  #
  # or
  #
  # permit_params do
  #   permitted = [:price, :city, :full_address, :reservation_date, :state, :zip_code]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end


  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :service_name
      f.input :booking_status
      f.input :city
      f.input :full_address
      f.input :zip_code
      f.input :state
      f.input :reservation_date, as: :datepicker
      f.input :price
      f.input :slot_start_time, as: :time_picker
      f.input :slot_end_time, as: :time_picker
      f.input :image, as: :file, hint: f.object.image.present? ? image_tag(url_for(f.object.image), size: "50x50") : content_tag(:span, "no product_image found") 
    end
    f.actions
  end


  show do
    attributes_table do
      row :booking_status
      row :service_name
      row :city
      row :full_address
      row :zip_code
      row :state
      row :reservation_date
      row :price
      row :slot_start_time
      row :slot_end_time
      row :image do |img|
        div do 
          image_tag url_for(img.image), size: "100x100" if img.image.present?
        end
      end
    end
  end
    
end
