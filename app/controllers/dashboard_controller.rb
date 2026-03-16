# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    @user = Current.user

    if @user.has_booking_access?
      my_bookings = @user.bookings.includes(class_schedule: [:class_type, :instructor])

      @upcoming_bookings = ClassSchedule.dashboard_upcoming
                                        .visible_for(@user)
                                        .includes(:class_type, :instructor, :bookings)
                                        .limit(20)   
      @past_bookings = @user.bookings.includes(class_schedule: [:class_type, :instructor])
                                      .merge(ClassSchedule.past_logical)
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
      @is_first_time = @user.memberships.none? && @user.drop_in_tickets.none?
    end
    
    # Case 3: If the user is pending_approval, the view will use directly @user.pending_approval?
  end
end
