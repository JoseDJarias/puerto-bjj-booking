class ProductOrderMailer < ApplicationMailer
  # Sends an immediate alert to admin when a user submits an order with payment receipt
  def admin_new_order_notification(product_order)
    @product_order = product_order
    @user = product_order.user
    @product = product_order.product

    # Collect admin emails or default administrator
    admin_emails = User.where(role: :admin).pluck(:email_address)
    admin_emails = ["infopuertobjj@gmail.com"] if admin_emails.empty?

    mail(
      to: admin_emails,
      subject: t("mailers.product_order_mailer.admin_new_order_notification.subject", user_name: @user.first_name, product_name: @product_order.product_name)
    )
  end

  # Sends confirmation to the user once the admin verifies the SINPE deposit
  def user_payment_confirmed_email(product_order)
    @product_order = product_order
    @user = product_order.user

    mail(
      to: @user.email_address,
      subject: t("mailers.product_order_mailer.user_payment_confirmed_email.subject", product_name: @product_order.product_name)
    )
  end

  # Notifies user when product has been officially ordered from supplier
  def user_ordered_from_supplier_email(product_order)
    @product_order = product_order
    @user = product_order.user

    mail(
      to: @user.email_address,
      subject: t("mailers.product_order_mailer.user_ordered_from_supplier_email.subject", product_name: @product_order.product_name)
    )
  end

  # Notifies user when product has physically arrived at the academy
  def user_ready_for_pickup_email(product_order)
    @product_order = product_order
    @user = product_order.user

    mail(
      to: @user.email_address,
      subject: t("mailers.product_order_mailer.user_ready_for_pickup_email.subject", product_name: @product_order.product_name)
    )
  end
end
