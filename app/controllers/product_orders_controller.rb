class ProductOrdersController < ApplicationController
  before_action :set_product, only: %i[new create]

  def index
    @orders = current_user.product_orders.includes(:product, payment_receipt_attachment: :blob).recent
  end

  def show
    @order = current_user.product_orders.find(params[:id])
  end

  def new
    @product_order = current_user.product_orders.build(product: @product)
  end

  def create
    @product_order = current_user.product_orders.build(order_params.merge(product: @product))

    if @product_order.save
      ProductOrderMailer.admin_new_order_notification(@product_order).deliver_later
      redirect_to my_order_path(@product_order), notice: t("product_orders.create.success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_product
    @product = Product.active.find(params[:product_id])
  end

  def order_params
    params.require(:product_order).permit(
      :user_notes,
      :terms_accepted,
      :payment_receipt
    )
  end
end
