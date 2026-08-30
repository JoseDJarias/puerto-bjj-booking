module Admin
  class ProductOrdersController < BaseController
    before_action :set_order, only: %i[show update confirm_payment mark_as_ordered mark_as_ready mark_as_delivered cancel_order]

    def index
      @orders = ProductOrder.includes(:user, payment_receipt_attachment: :blob).recent

      if params[:status].present? && ProductOrder.statuses.key?(params[:status])
        @orders = @orders.where(status: params[:status])
      end
    end

    def show
    end

    def update
      if @order.update(order_params)
        redirect_to admin_product_order_path(@order), notice: t("admin.products.update.success")
      else
        render :show, status: :unprocessable_entity
      end
    end

    # Confirm student payment deposit and send automated email
    def confirm_payment
      if @order.payment_confirmed!
        ProductOrderMailer.user_payment_confirmed_email(@order).deliver_later
        redirect_to admin_product_order_path(@order), notice: t("admin.product_orders.actions.payment_confirmed")
      else
        redirect_to admin_product_order_path(@order), alert: t("common.error")
      end
    end

    # Mark product as officially ordered from supplier and send email
    def mark_as_ordered
      if @order.ordered_from_supplier!
        ProductOrderMailer.user_ordered_from_supplier_email(@order).deliver_later
        redirect_to admin_product_order_path(@order), notice: t("admin.product_orders.actions.ordered_from_supplier")
      else
        redirect_to admin_product_order_path(@order), alert: t("common.error")
      end
    end

    # Mark product as arrived at academy and ready for pickup
    def mark_as_ready
      if @order.ready_for_pickup!
        ProductOrderMailer.user_ready_for_pickup_email(@order).deliver_later
        redirect_to admin_product_order_path(@order), notice: t("admin.product_orders.actions.ready_for_pickup")
      else
        redirect_to admin_product_order_path(@order), alert: t("common.error")
      end
    end

    # Mark order as completed and handed over
    def mark_as_delivered
      if @order.delivered!
        redirect_to admin_product_order_path(@order), notice: t("admin.product_orders.actions.delivered")
      else
        redirect_to admin_product_order_path(@order), alert: t("common.error")
      end
    end

    # Cancel the order
    def cancel_order
      if @order.cancelled!
        redirect_to admin_product_order_path(@order), notice: t("admin.product_orders.actions.cancelled")
      else
        redirect_to admin_product_order_path(@order), alert: t("common.error")
      end
    end

    private

    def set_order
      @order = ProductOrder.find(params[:id])
    end

    def order_params
      params.require(:product_order).permit(:admin_notes)
    end
  end
end
