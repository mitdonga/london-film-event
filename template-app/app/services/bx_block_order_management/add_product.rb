# frozen_string_literal: true

module BxBlockOrderManagement
  class AddProduct
    attr_accessor :params, :quantity, :catalogue, :order, :user, :catalogue_variant

    def initialize(params, user)
      @params = params
      @quantity = params[:quantity]
      @catalogue_id = params[:catalogue_id]
      @catalogue = BxBlockCatalogue::Catalogue.find(@catalogue_id)

      @catalogue_variant = @catalogue.catalogue_variants.find_by(id: params[:catalogue_variant_id])
      @user = user
    end

    def call
      if params[:catalogue_variant_id].present? && catalogue_variant.blank?
        OpenStruct.new(
          success?: false,
          data: nil,
          msg: "Sorry, Product Variant is not found for this product",
          code: 404
        )
      elsif product_not_available?
        OpenStruct.new(
          success?: false,
          data: nil,
          msg: "Sorry, Product is out of stock",
          code: 404
        )
      else

        @order = if params[:cart_id].present?
          Order.find_by_id(params[:cart_id])
        else
          Order.create!(
            account_id: user.id,
            status: "created",
            coupon_code_id: params[:coupon_code_id],
            amount: params[:amount]
          )
        end

        if order.blank?
          OpenStruct.new(
            success?: false,
            data: nil,
            msg: "Sorry, cart is not found",
            code: 404
          )
        else
          order.order_items.create!(order_item_params)
          msg = "Item added in cart successfully" if params[:cart_id].present?
          msg = "Order created successfully" unless params[:cart_id].present?
          OpenStruct.new(success?: true, data: order, msg: msg, code: 200)
        end
      end
    end

    private

    def product_not_available?
      check_order_qty = Order.includes(:order_items).where(order_items: {catalogue_variant_id: @catalogue_variant.id}).sum(:quantity)

      quantity.to_i > if catalogue_variant.present?
        (@catalogue_variant.stock_qty.to_i - @catalogue_variant.block_qty.to_i - check_order_qty || 0)
      else
        (@catalogue.stock_qty.to_i - @catalogue.block_qty.to_i - check_order_qty || 0)
      end
    end

    def order_item_params
      params.permit(:quantity, :catalogue_id, :catalogue_variant_id)
    end

    def card_params
      {
        number: params[:number],
        exp_month: params[:exp_month],
        exp_year: params[:exp_year],
        cvc: params[:cvc]
      }
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize
