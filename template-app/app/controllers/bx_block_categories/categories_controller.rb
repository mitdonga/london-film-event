# frozen_string_literal: true

module BxBlockCategories
  class CategoriesController < ApplicationController
    before_action :load_category, only: %i[show update destroy]
    before_action :current_user

    def create
      err = []

      categories_params.map do |x|
        name_validation = x.permit(:name).to_h
        err << "name can't be blank" unless name_validation[:name].present?
      end

      return render json: {message: err.uniq}, status: :unprocessable_entity unless !err.present?
      @categories = Category.create!(categories_params)

      if @categories
        render json: CategorySerializer.new(@categories, serialization_options)
          .serializable_hash,
          status: :created
      end
    rescue
      categories_params.map do |x|
        name_validation = x.permit(:name).to_h
        if Category.where(name: name_validation[:name]).present?
          err << "name can't be use #{name_validation[:name]}"
        end
      end
      render json: {message: err}, status: :unprocessable_entity
    end

    def show
      return if @category.nil?

      render json: CategorySerializer.new(@category, serialization_options)
        .serializable_hash,
        status: :ok
    end

    def index
      services = params[:no_bespoke] == "true" || params[:no_bespoke] == true ? @current_user.available_services.where.not("categories.name ilike ?", "%bespoke%") : @current_user.available_services
      if services.size > 0
        render json: BxBlockCategories::CategorySerializer.new(services, {params: {account: @current_user}, meta: { message: "Available services: #{services.size}"}}).serializable_hash, status: :ok
      else
        render json: { message: "Unfortunately, there are no services available for you at the moment" }, status: 204
      end
    end

    def previous_packages
      past_service_ids = BxBlockInvoice::Inquiry.where(user: @current_user).pluck(:service_id).uniq
      services = @current_user.available_services.where(id: past_service_ids)
      if services.size > 0
        render json: BxBlockCategories::CategorySerializer.new(services, {params: {account: @current_user}, meta: { message: "Available previous packages: #{services.size}"}}).serializable_hash, status: :ok
      else
        render json: { message: "Previous packages not found" }, status: 204
      end
    end

    def destroy
      return if @category.nil?

      begin
        if @category.destroy
          remove_not_used_subcategories

          render json: {success: true}, status: :ok
        end
      rescue ActiveRecord::InvalidForeignKey
        message = "Record can't be deleted due to reference to a catalogue " \
                  "record"

        render json: {
          error: {message: message}
        }, status: :internal_server_error
      end
    end

    def update
      return if @category.nil?

      update_result = @category.update(update_categories_params)

      if update_result
        render json: CategorySerializer.new(@category).serializable_hash,
          status: :ok
      else
        render json: ErrorSerializer.new(@category).serializable_hash,
          status: :unprocessable_entity
      end
    end

    def update_user_categories
      categories = Category.where(id: params[:categories_ids])
      category_ids = categories.map(&:id)

      return render json: {errors: "Category ID #{(params[:categories_ids].map(&:to_i) - category_ids).join(",")} not found"}, status: :unprocessable_entity unless category_ids.count == params[:categories_ids].count
      if categories.present?
        UserCategory.where(account_id: current_user.id).delete_all
        params[:categories_ids].each do |cat_id|
          UserCategory.create!(account_id: current_user.id, category_id: cat_id)
        end
        categories = Category.joins(:user_categories).where(user_categories: {account_id: current_user.id})
        render json: CategorySerializer.new(categories).serializable_hash,
          status: :ok
      end
    end

    def get_service
      sub_category_id = params[:sub_category_id]
      sub_category = SubCategory.find_by_id(sub_category_id)
      return render json: { message: "Invalid sub category" }, status: :unprocessable_entity unless sub_category.present?
      render json: { service: CategorySerializer.new(sub_category.parent, {params: {account: @current_user}}).serializable_hash }, status: :ok
    end

    def form_fields
      return render json: { message: "Provide valid service and sub category ids" }, status: :unprocessable_entity unless params[:service_id].present? && params[:sub_category_id].present?
      service = @current_user.available_services.find_by(id: params[:service_id])
      sub_category = @current_user.available_sub_categories.find_by(id: params[:sub_category_id], parent_id: service&.id)
      return render json: { message: "Service or sub category not found" }, status: :unprocessable_entity unless service.present? && sub_category.present?
      input_fields = service.input_fields
      default_coverages = sub_category.default_coverages
      render json: { input_fields: InputFieldSerializer.new(input_fields).serializable_hash, default_coverages: DefaultCoverageSerializer.new(default_coverages).serializable_hash }, status: :ok
    end

    private

    def categories_params
      params.permit(categories: [:name, light_icon: {}, light_icon_active: {}, light_icon_inactive: {}, dark_icon: {}, dark_icon_active: {}, dark_icon_inactive: {}]).require(:categories)
    end

    def update_categories_params
      params.require(:categories).permit(:name, light_icon: {}, light_icon_active: {}, light_icon_inactive: {}, dark_icon: {}, dark_icon_active: {}, dark_icon_inactive: {})
    end

    def load_category
      @category = Category.find_by(id: params[:id])

      if @category.nil?
        render json: {
          message: "Category with id #{params[:id]} doesn't exists"
        }, status: :not_found
      end
    end

    def serialization_options
      options = {}
      options[:params] = {sub_categories: true}
      options
    end

    def remove_not_used_subcategories
      sql = "delete from sub_categories sc where sc.id in (
               select sc.id from sub_categories sc
               left join categories_sub_categories csc on
                 sc.id = csc.sub_category_id
               where csc.sub_category_id is null
             )"
      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
