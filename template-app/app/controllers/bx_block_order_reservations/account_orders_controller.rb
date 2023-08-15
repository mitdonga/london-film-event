module BxBlockOrderReservations
  class AccountOrdersController < ApplicationController
    include Pagination

    before_action :find_current_user
    
    def index
      user_orders = @current_user.account_orders
      user_orders = Kaminari.paginate_array(user_orders).page(params[:page] || 1).per(params[:per] || 10)
      serializer = BxBlockOrderReservations::AccountOrderSerializer.new(user_orders).serializable_hash
      render json: serializer.merge(meta: page_meta(user_orders)), status: :ok
    end

    def create
      if params["user_orders"].present?
        user_orders = []       
        reservations = BxBlockOrderReservations::ReservationService.where(id: params.as_json["user_orders"].pluck("reservation_service_id")).booked
        return render json: {message: "reservation service is already booked with reservation_service_id #{reservations&.ids}"}, status: :unprocessable_entity if reservations.present?
        params["user_orders"].each do |u_order|
          user_order = BxBlockOrderReservations::AccountOrder.new(reservation_service_id: u_order["reservation_service_id"], quantity: u_order["quantity"], placed_date_time: DateTime.now, account_id: @current_user&.id, order_status: "placed")
          if user_order.save
            user_orders << user_order  
          else
            return render json: {errors: user_order.errors.full_messages}, status: 402
          end
        end        
        return render json: BxBlockOrderReservations::AccountOrderSerializer.new(user_orders).serializable_hash, status: :ok
      else
        render json: {message: "request params not found"}, status: 404       
      end
    end

    def update
      user_order = BxBlockOrderReservations::AccountOrder.find_by(id: params[:id], account_id: @current_user["id"])
      if user_order.present? 
          user_order.reservation_service.update_column(:booking_status, "availabile")
        if user_order.update(menu_params) 
           return render json: BxBlockOrderReservations::AccountOrderSerializer.new(user_order).serializable_hash, status: :ok
        else
          return render json: {errors: user_order.errors.full_messages}, status: 402
        end
      else
        return render json: {message: "Record not found"}, status: 404
      end
    end

    def destroy
      user_order = BxBlockOrderReservations::AccountOrder.find_by(id: params[:id], account_id: @current_user["id"])
      if user_order.present? && user_order.update_column(:order_status, "cancelled") && user_order.reservation_service.update_column(:booking_status, "availabile")
        return render json: BxBlockOrderReservations::AccountOrderSerializer.new(user_order).serializable_hash, status: :ok
      else
        return render json: {message: "Record not found"}, status: 404        
      end
    end

    private

    def menu_params
      params.require(:user_order).permit(:id, :reservation_service_id, :quantity)
    end

  end
end