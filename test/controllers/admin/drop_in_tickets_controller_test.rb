require "test_helper"

class Admin::DropInTicketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student = users(:one)
    @ticket = DropInTicket.create!(user: @student, price_paid: 5000, status: :unused)
  end

  test "should redirect create if not admin" do
    sign_in_as(@student)
    assert_queries_count(2..6) do
      post admin_user_drop_in_tickets_path(@student), params: { quantity: 2 }
    end
    assert_redirected_to root_path
  end

  test "should create drop in tickets" do
    sign_in_as(@admin)
    
    assert_difference -> { @student.drop_in_tickets.count }, 2 do
      assert_queries_count(2..15) do
        post admin_user_drop_in_tickets_path(@student), params: { quantity: 2 }
      end
    end
    
    assert_redirected_to admin_user_path(@student)
  end

  test "should void drop in ticket" do
    sign_in_as(@admin)
    
    assert_queries_count(2..15) do
      patch void_admin_user_drop_in_ticket_path(@student, @ticket)
    end
    
    assert_redirected_to admin_user_path(@student)
    @ticket.reload
    assert_equal "voided", @ticket.status
  end

  test "should reset drop in ticket usage" do
    sign_in_as(@admin)
    @ticket.used!
    
    assert_queries_count(2..15) do
      patch reset_usage_admin_user_drop_in_ticket_path(@student, @ticket)
    end
    
    assert_redirected_to admin_user_path(@student)
    @ticket.reload
    assert_equal "unused", @ticket.status
  end

  test "should destroy drop in ticket" do
    sign_in_as(@admin)
    
    assert_difference -> { @student.drop_in_tickets.count }, -1 do
      assert_queries_count(2..15) do
        delete admin_user_drop_in_ticket_path(@student, @ticket)
      end
    end
    
    assert_redirected_to admin_user_path(@student)
  end
end
