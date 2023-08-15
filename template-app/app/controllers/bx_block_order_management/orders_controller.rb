# frozen_string_literal: true

module BxBlockOrderManagement
  class OrdersController < BxBlockOrderManagement::ApplicationController
    before_action :check_order_item, only: %i[show destroy]
    before_action :check_order,
      only: %i[update_payment_source update_order_status update_custom_label edit_custom_label add_address_to_order
        apply_coupon add_order_items remove_order_items]
    before_action :address, only: [:add_address_to_order]

    def index
      orders = Order.includes(
        :coupon_code, order_items: [catalogue: %i[category sub_category brand]]
      ).where(
        account_id: @current_user.id
      ).order(created_at: :desc)
      if orders.present?
        render json: OrderSerializer.new(orders, serializable_options), status: 200
      else
        render json: {message: "No order record found."}, status: 404
      end
    end

    def create
      if params[:quantity].present? && params[:quantity] > 0
        if params[:catalogue_variant_id].present?
          @res = AddProduct.new(params, @current_user).call
          update_cart_total(@res.data) if @res.success?
          if @res.success? && !@res.data.nil?
            order = Order.includes(
              :coupon_code, order_items: [catalogue: %i[category sub_category brand]]
            ).find(@res.data.id)
            render json: {
              data:
                {
                  coupon_message: if @cart_response.nil? || @cart_response.success?
                                    nil
                                  else
                                    @cart_response.msg
                                  end,
                  order: OrderSerializer.new(
                    order,
                    {
                      params: {
                        user: @current_user,
                        host: request.protocol + request.host_with_port
                      }
                    }
                  )
                }
            }, status: "200"
          else
            render json: {errors: @res.msg}, status: @res.code
          end
        else
          render json: {msg: "catalogue_variant_id must be define"}, status: 422
        end
      else
        render json: {msg: "quantity must be greater than 0"}, status: 422
      end
    end

    def show
      render json: OrderSerializer.new(
        @order,
        {params: {order: true, host: request.protocol + request.host_with_port}}
      ).serializable_hash, status: :ok
    end

    def update_order_status
      if @order.in_cart? || @order.cancelled?
        render json: {error: "Your order is in cart."},
          status: :unprocessable_entity
      else
        ActiveRecord::Base.transaction do
          @order.update!(status: params[:status])
          render json: OrderSerializer.new(@order, serializable_options), status: 200
        end
      end
    end

    def cancel_order
      order = Order.find_by({account_id: @current_user.id, id: params[:order_id]})
      render json: {errors: ["Record not found"]}, status: 404 and return unless order.present?

      order_status_id = OrderStatus.find_or_create_by(
        status: "cancelled", event_name: "cancel_order"
      ).id
      if order.in_cart?
        render json: {error: "Your order is in cart. so no need to cancel it"},
          status: :unprocessable_entity
      elsif order.status == "cancelled"
        render json: {message: "Order already cancelled"},
          status: :ok
      else
        begin
          ActiveRecord::Base.transaction do
            order.order_items.map do |a|
              a.update(
                order_status_id: order_status_id, cancelled_at: Time.current
              )
            end
            if order.full_order_cancelled?
              order.update(
                order_status_id: order_status_id,
                status: "cancelled",
                cancelled_at: Time.current
              )
            end
          end
        rescue => e
          render json: {error: e}
        end
        render json: {message: "Order cancelled successfully"},
          status: :ok
      end
    end

    def destroy
      if @order.account_id == @current_user.id
        @order.destroy
        if @order.destroyed?
          render json: {message: "Order deleted successfully"}, status: :ok
        else
          render json: "Order ID does not exist", status: 404
        end
      end
    end

    def add_address_to_order
      x = AddAddressToOrder.new(params, @current_user).call
      @order.update(delivery_address_id: params[:address_id])
      render json: {message: x.msg}, status: x.code
    end

    def apply_coupon
      if @order.status == "in_cart"
        @coupon = BxBlockCouponCg::CouponCode.find_by_code(params[:code])
        render(json: {message: "Invalid coupon"}, status: 400) && return if @coupon.nil?
        if @order.amount.present? && @order.amount < @coupon.min_cart_value
          return render json: {message: "Keep shopping to apply the coupon"}, status: 400
        end

        result = ApplyCoupon.new(@order, @coupon, params).call
        render json: {
          data: {
            coupon: OrderSerializer.new(@order), message: result.msg
          }
        }, status: 200
      else
        render json: {message: "Order not is in_cart"}
      end
    end

    def update_custom_label
      if params[:custom_label].present?
        if @order.update!(custom_label: params[:custom_label])
          render json: OrderSerializer.new(@order, serializable_options), status: 200
        end
      else
        render json: {msg: "custom_label must be define"}, status: 422
      end
    end

    # TODO: duplication
    def edit_custom_label
      if params[:custom_label].present?
        if @order.update!(custom_label: params[:custom_label])
          render json: OrderSerializer.new(@order, serializable_options), status: 200
        end
      else
        render json: {msg: "custom_label must be define"}, status: 422
      end
    end

    def add_order_items
      err = []

      order_item_params.each do |oip|
        unless oip["quantity"].present? && oip["quantity"] > 0
          err << "quantity must be greater than 0"
        end

        if oip["catalogue_variant_id"].present?
          catalogue_variant = BxBlockCatalogue::CatalogueVariant.find_by(id: oip["catalogue_variant_id"])
          unless catalogue_variant.present?
            err << "catalogue_variant_id does not exist"
          end

          if catalogue_variant.present? && (oip["quantity"].present? && oip["quantity"] > 0)
            check_order_qty = Order.includes(:order_items).where(order_items: {catalogue_variant_id: oip["catalogue_variant_id"]}).sum(:quantity)
            unless catalogue_variant.stock_qty.to_i >= (check_order_qty + oip["quantity"])
              err << "Sorry, Product is out of stock for catalogue variant id #{oip["catalogue_variant_id"]}"
            end
          end
        else
          err << "catalogue_variant_id must be define"
        end

        if oip["catalogue_id"].present?
          unless BxBlockCatalogue::Catalogue.find_by(id: oip["catalogue_id"])
            err << "catalogue_id does not exist"
          end
        else
          err << "catalogue_id must be define"
        end
      end

      if @order.status == "in_cart" || @order.status == "created"
        if !err.present?
          @order.order_items.create!(order_item_params)
          render json: OrderSerializer.new(@order, serializable_options), status: 200
        else
          render json: {message: err.uniq}, status: 422
        end
      else
        render json: {message: "Order not is in_cart or created"}
      end
    end

    def remove_order_items
      if @order.status == "in_cart" || @order.status == "created"
        if params[:order_items_ids].present?
          err = []
          msg = []
          params[:order_items_ids].each do |oid|
            if OrderItem.find_by(id: oid, order_management_order_id: params[:order_id])
              msg << oid
            else
              err << oid
            end
          end

          if !err.present?
            OrderItem.destroy(msg)
            render json: {message: "Order Items are deleted successfully"}, status: 200
          else
            render json: {message: "Order Items ids are does not exist with #{err}"}, status: 422
          end
        else
          render json: {message: "Order Items ids are does not exist"}, status: 422
        end
      else
        render json: {message: "Order not is in_cart or created"}, status: 422
      end
    end

    private

    def address
      @address = DeliveryAddress.find_by(id: params[:address_id])
      render json: {message: "Delivery ID does not exist"}, status: 404 unless @address
    end

    def check_order_item
      @order = Order.find_by(account_id: @current_user.id, id: params[:id])
      unless @order
        render json: {message: "Order ID does not exist (or) Order Id does not belongs to current user"},
          status: 404
      end
    end

    def check_order
      @order = Order.find_by(account_id: @current_user.id, id: params[:order_id])
      unless @order
        render json: {message: "Order ID does not exist (or) Order Id does not belongs to current user"},
          status: 404
      end
    end

    def update_cart_total(order)
      @cart_response = UpdateCartValue.new(order, @current_user).call
    end

    def order_params
      params.permit(
        :quantity, :catalogue_id, :catalogue_variant_id, :order_number, :amount, :account_id,
        :delivery_address_id, :sub_total, :total, :status, :applied_discount, :cancellation_reason, :order_date,
        :is_gift, :placed_at, :confirmed_at, :in_transit_at, :delivered_at, :cancelled_at, :refunded_at,
        :source, :shipment_id, :delivery_charges, :tracking_url, :schedule_time, :payment_failed_at, :returned_at,
        :tax_charges, :deliver_by, :tracking_number, :is_error, :delivery_error_message, :payment_pending_at, :order_status_id,
        :is_group, :is_availability_checked, :shipping_charge, :shipping_discount, :shipping_net_amt, :shipping_total, :total_tax,
        :razorpay_order_id, :charged, :invoiced, :invoice_id
      )
    end

    def serializable_options
      {params: {host: request.protocol + request.host_with_port}}
    end

    def order_item_params
      params.permit(order_items: %i[quantity catalogue_id catalogue_variant_id]).require(:order_items)
    end
  end
end

# rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/ClassLength, Layout/LineLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
