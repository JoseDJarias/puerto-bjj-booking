require "test_helper"

class ProductOrderMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:one)
    @product = products(:rashguard)
    @order = @user.product_orders.create!(
      product: @product,
      terms_accepted: true,
      payment_receipt: {
        io: StringIO.new("fake receipt content"),
        filename: "receipt.png",
        content_type: "image/png"
      }
    )
  end

  test "admin_new_order_notification" do
    email = ProductOrderMailer.admin_new_order_notification(@order)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["admin@puertobjj.com"], email.to
    assert_includes email.subject, @product.name
    assert_includes email.body.encoded, @user.first_name
  end

  test "user_payment_confirmed_email" do
    email = ProductOrderMailer.user_payment_confirmed_email(@order)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email_address], email.to
    assert_includes email.subject, @product.name
  end

  test "user_ordered_from_supplier_email" do
    email = ProductOrderMailer.user_ordered_from_supplier_email(@order)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email_address], email.to
    assert_includes email.subject, @product.name
  end

  test "user_ready_for_pickup_email" do
    email = ProductOrderMailer.user_ready_for_pickup_email(@order)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email_address], email.to
    assert_includes email.subject, @product.name
  end
end
