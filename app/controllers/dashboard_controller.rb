# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    @user = Current.user

    if @user.has_booking_access?
      my_bookings = @user.bookings.active.includes(class_schedule: [:class_type, :instructor])

      @upcoming_bookings = my_bookings.where("class_schedules.starts_at >= ?", Time.current)
                                      .references(:class_schedules)
                                      .order("class_schedules.starts_at ASC")

      @past_bookings = my_bookings.where("class_schedules.starts_at < ?", Time.current)
                                  .references(:class_schedules)
                                  .order("class_schedules.starts_at DESC")
                                  .limit(20)

      # Statistics for the Stats Cards
      @total_attended = @user.bookings.attended.count
      @month_attended = @user.bookings.attended
                             .joins(:class_schedule)
                             .where(class_schedules: { starts_at: Time.current.beginning_of_month..Time.current.end_of_month })
                             .count
      # Memberships Stats 
      @active_memberships = @user.memberships.current.includes(:membership_package, :membership_plan)
      @unused_tickets_count = @user.drop_in_tickets.unused.count                    
    # Case 2: Approved but needs to buy a plan
    elsif @user.approved?
      @packages = MembershipPackage.active.includes(:class_types)
      @plans = MembershipPlan.active.order(duration_months: :asc)
    end
    
    # Case 3: If the user is pending_approval, the view will use directly @user.pending_approval?
  end
end
