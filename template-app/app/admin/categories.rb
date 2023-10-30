ActiveAdmin.register BxBlockCategories::Category, as: "Categories" do
    menu false
    permit_params :name, :light_image, :light_icon_active, :light_icon_inactive, :dark_image, :dark_icon_active, :dark_icon_inactive, :identifier

  
end